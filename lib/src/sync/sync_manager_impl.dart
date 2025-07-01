import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../core/interfaces/sync_manager.dart';
import '../core/interfaces/connectivity_service.dart';
import '../core/models/sync_item.dart';
import '../core/models/sync_result.dart';
import '../core/models/upload_status.dart';
import '../database/sync_database.dart';
import '../utils/retry_policy.dart';
import '../utils/sync_utils.dart';
import '../core/exceptions/offline_exceptions.dart';
import '../annotations/offline_entity.dart';

/// Implementation of SyncManager that handles sync operations
class SyncManagerImpl implements SyncManager {
  SyncManagerImpl({
    required this.database,
    required this.connectivityService,
    required this.dio,
    RetryPolicy? retryPolicy,
  }) : _retryPolicy = retryPolicy ?? ExponentialBackoffRetryPolicy();

  final SyncDatabase database;
  final ConnectivityService connectivityService;
  final Dio dio;
  final RetryPolicy _retryPolicy;

  final Map<String, SyncHandler> _syncHandlers = {};
  final StreamController<SyncStatus> _statusController = StreamController.broadcast();
  final StreamController<SyncProgress> _progressController = StreamController.broadcast();
  final StreamController<List<SyncItem>> _queueController = StreamController.broadcast();

  StreamSubscription? _connectivitySubscription;
  SyncStrategy _syncStrategy = SyncStrategy.immediate;
  bool _isInitialized = false;
  bool _isSyncing = false;
  bool _autoSyncEnabled = false;
  Timer? _syncTimer;
  Timer? _retryTimer;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Listen to connectivity changes
      _connectivitySubscription = connectivityService.watchConnectivity().listen(
        (isConnected) {
          if (isConnected && _autoSyncEnabled && !_isSyncing) {
            _triggerSync();
          }
        },
      );

      // Start retry timer for failed items
      _startRetryTimer();

      _isInitialized = true;
      _statusController.add(SyncStatus.idle);
    } catch (e) {
      throw NotInitializedException(
        'Failed to initialize SyncManager: $e',
        serviceName: 'SyncManager',
      );
    }
  }

  @override
  Future<void> queueForSync(SyncItem item) async {
    _ensureInitialized();

    try {
      // Validate the sync item
      if (!SyncUtils.validateSyncItem(item)) {
        throw ValidationException(
          'Invalid sync item data',
          fieldName: 'data',
          value: item.data,
        );
      }

      // Insert into sync queue using custom SQL without relying on table getters
      await database.customInsert(
        '''
        INSERT OR REPLACE INTO sync_items 
        (id, entity_type, entity_id, data, created_at, status, priority, endpoint, last_attempt_at, dependencies)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        variables: [
          Variable.withString(item.id),
          Variable.withString(item.entityType),
          Variable.withString(item.entityId),
          Variable.withString(jsonEncode(item.data)),
          Variable.withDateTime(item.createdAt),
          Variable.withString(jsonEncode(item.status.toJson())),
          Variable.withInt(item.priority.value),
          Variable(item.endpoint),
          Variable(item.lastAttemptAt),
          Variable.withString(jsonEncode(item.dependencies)),
        ],
      );

      // Notify watchers
      final currentQueue = await getSyncQueue();
      _queueController.add(currentQueue);

      // Trigger sync if conditions are met
      if (_shouldTriggerImmediateSync()) {
        _triggerSync();
      }
    } catch (e) {
      throw SyncException(
        'Failed to queue item for sync: $e',
        entityType: item.entityType,
        entityId: item.entityId,
      );
    }
  }

  @override
  Future<void> queueMultipleForSync(List<SyncItem> items) async {
    _ensureInitialized();

    try {
      await database.transaction(() async {
        for (final item in items) {
          await queueForSync(item);
        }
      });
    } catch (e) {
      throw SyncException('Failed to queue multiple items for sync: $e');
    }
  }

  @override
  Future<void> startAutoSync() async {
    _ensureInitialized();
    _autoSyncEnabled = true;

    if (await connectivityService.isConnected()) {
      await syncNow();
    }

    // Set up periodic sync based on strategy
    if (_syncStrategy == SyncStrategy.scheduled) {
      _startScheduledSync();
    }
  }

  @override
  Future<void> stopAutoSync() async {
    _autoSyncEnabled = false;
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  @override
  Future<void> syncNow() async {
    _ensureInitialized();

    if (_isSyncing) {
      return; // Already syncing
    }

    if (!await connectivityService.isConnected()) {
      _statusController.add(SyncStatus.paused);
      return;
    }

    _isSyncing = true;
    _statusController.add(SyncStatus.syncing);

    try {
      final pendingItems = await getSyncQueueByStatus([UploadState.pending]);

      if (pendingItems.isEmpty) {
        _statusController.add(SyncStatus.idle);
        return;
      }

      // Sort items by priority and dependencies
      final sortedItems = SyncUtils.topologicalSort(pendingItems);

      await _syncItems(sortedItems);

      _statusController.add(SyncStatus.idle);
    } catch (e) {
      _statusController.add(SyncStatus.error);
      throw SyncException('Sync operation failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  @override
  Future<void> retryFailed() async {
    _ensureInitialized();

    try {
      final failedItems = await getSyncQueueByStatus([UploadState.failed]);

      for (final item in failedItems) {
        if (item.status.canRetry) {
          await _updateSyncItemStatus(
            item.id,
            item.status.copyWith(
              state: UploadState.pending,
              error: null,
            ),
          );
        }
      }

      if (failedItems.isNotEmpty) {
        await syncNow();
      }
    } catch (e) {
      throw SyncException('Failed to retry failed items: $e');
    }
  }

  @override
  Future<SyncResult> retrySyncItem(String syncItemId) async {
    _ensureInitialized();

    try {
      final item = await _getSyncItemById(syncItemId);
      if (item == null) {
        return SyncResult.failure('Sync item not found: $syncItemId');
      }

      if (!item.status.canRetry) {
        return SyncResult.failure('Item cannot be retried (retry limit exceeded)');
      }

      // Reset status to pending
      await _updateSyncItemStatus(
        syncItemId,
        item.status.copyWith(
          state: UploadState.pending,
          error: null,
        ),
      );

      // Attempt to sync the single item
      return await _syncSingleItem(item);
    } catch (e) {
      return SyncResult.failure('Failed to retry sync item: $e');
    }
  }

  @override
  Future<void> cancelSyncItem(String syncItemId) async {
    _ensureInitialized();

    try {
      await _updateSyncItemStatus(
        syncItemId,
        const UploadStatus(state: UploadState.cancelled),
      );

      final currentQueue = await getSyncQueue();
      _queueController.add(currentQueue);
    } catch (e) {
      throw SyncException('Failed to cancel sync item: $e');
    }
  }

  @override
  Future<void> clearCompleted() async {
    _ensureInitialized();

    try {
      await database.customUpdate(
        'DELETE FROM sync_items WHERE status LIKE ?',
        variables: [Variable.withString('%"state":"completed"%')],
      );

      final currentQueue = await getSyncQueue();
      _queueController.add(currentQueue);
    } catch (e) {
      throw DatabaseException(
        'Failed to clear completed items: $e',
        tableName: 'sync_items',
        operation: 'delete',
      );
    }
  }

  @override
  Future<List<SyncItem>> getSyncQueue() async {
    _ensureInitialized();

    try {
      final results = await database.customSelect(
        '''
        SELECT * FROM sync_items 
        ORDER BY priority DESC, created_at ASC
        ''',
      ).get();

      return results.map((row) => _convertRowToSyncItem(row.data)).toList();
    } catch (e) {
      throw DatabaseException(
        'Failed to get sync queue: $e',
        tableName: 'sync_items',
        operation: 'select',
      );
    }
  }

  @override
  Future<List<SyncItem>> getSyncQueueByStatus(List<UploadState> states) async {
    _ensureInitialized();

    try {
      final allItems = await getSyncQueue();
      return allItems.where((item) => states.contains(item.status.state)).toList();
    } catch (e) {
      throw DatabaseException(
        'Failed to get sync queue by status: $e',
        tableName: 'sync_items',
        operation: 'select',
      );
    }
  }

  @override
  Future<SyncStatistics> getSyncStatistics() async {
    _ensureInitialized();

    try {
      final allItems = await getSyncQueue();
      final totalSynced = allItems.where((item) => item.status.isCompleted).length;
      final totalFailed = allItems.where((item) => item.status.isFailed).length;

      // Calculate average sync time from completed items
      final completedItems = allItems.where((item) => item.status.isCompleted && item.status.uploadedAt != null);

      Duration averageSyncTime = const Duration(seconds: 30);
      if (completedItems.isNotEmpty) {
        final totalTime = completedItems.fold<Duration>(
          Duration.zero,
          (sum, item) => sum + (item.status.uploadedAt!.difference(item.createdAt)),
        );
        averageSyncTime = Duration(
          milliseconds: totalTime.inMilliseconds ~/ completedItems.length,
        );
      }

      final lastSyncAt = completedItems.isNotEmpty ? completedItems.map((item) => item.status.uploadedAt!).reduce((a, b) => a.isAfter(b) ? a : b) : null;

      return SyncStatistics(
        totalSynced: totalSynced,
        totalFailed: totalFailed,
        averageSyncTime: averageSyncTime,
        lastSyncAt: lastSyncAt,
      );
    } catch (e) {
      throw SyncException('Failed to get sync statistics: $e');
    }
  }

  @override
  Stream<List<SyncItem>> watchSyncQueue() {
    _ensureInitialized();

    // Simple polling approach using custom SQL
    return Stream.periodic(const Duration(seconds: 2), (_) => null).asyncMap((_) async => await getSyncQueue()).distinct();
  }

  @override
  Stream<SyncStatus> watchSyncStatus() {
    _ensureInitialized();
    return _statusController.stream;
  }

  @override
  Stream<SyncProgress> watchSyncProgress() {
    _ensureInitialized();
    return _progressController.stream;
  }

  @override
  void setSyncStrategy(SyncStrategy strategy) {
    _syncStrategy = strategy;

    if (strategy == SyncStrategy.scheduled && _autoSyncEnabled) {
      _startScheduledSync();
    } else {
      _syncTimer?.cancel();
      _syncTimer = null;
    }
  }

  @override
  void registerSyncHandler(String entityType, SyncHandler handler) {
    _syncHandlers[entityType] = handler;
  }

  @override
  Future<void> dispose() async {
    _autoSyncEnabled = false;
    await _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    _retryTimer?.cancel();

    await _statusController.close();
    await _progressController.close();
    await _queueController.close();

    _isInitialized = false;
  }

  // Private helper methods

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw NotInitializedException(
        'SyncManager not initialized. Call initialize() first.',
        serviceName: 'SyncManager',
      );
    }
  }

  void _triggerSync() {
    // Use a timer to prevent rapid successive sync triggers
    Timer(const Duration(seconds: 1), () {
      if (!_isSyncing && _autoSyncEnabled) {
        syncNow();
      }
    });
  }

  bool _shouldTriggerImmediateSync() {
    return _syncStrategy == SyncStrategy.immediate && _autoSyncEnabled && !_isSyncing;
  }

  void _startScheduledSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_autoSyncEnabled && !_isSyncing) {
        syncNow();
      }
    });
  }

  void _startRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(minutes: 2), (_) async {
      if (!_isSyncing) {
        await _retryReadyItems();
      }
    });
  }

  Future<void> _retryReadyItems() async {
    try {
      final failedItems = await getSyncQueueByStatus([UploadState.failed]);
      final readyItems = failedItems.where((item) => item.status.nextRetryAt != null && DateTime.now().isAfter(item.status.nextRetryAt!)).toList();

      for (final item in readyItems) {
        await _updateSyncItemStatus(
          item.id,
          item.status.copyWith(state: UploadState.pending),
        );
      }

      if (readyItems.isNotEmpty && _autoSyncEnabled) {
        _triggerSync();
      }
    } catch (e) {
      // Log error but don't throw
      debugPrint('Error in retry timer: $e');
    }
  }

  Future<void> _syncItems(List<SyncItem> items) async {
    final total = items.length;
    var completed = 0;
    var failed = 0;
    var inProgress = 0;

    for (final item in items) {
      if (!await connectivityService.isConnected()) {
        _statusController.add(SyncStatus.paused);
        break;
      }

      inProgress++;
      _emitProgress(total, completed, failed, inProgress);

      try {
        await _updateSyncItemStatus(
          item.id,
          item.status.copyWith(state: UploadState.uploading),
        );

        final result = await _syncSingleItem(item);

        if (result.success) {
          await _updateSyncItemStatus(
            item.id,
            item.status.copyWith(
              state: UploadState.completed,
              uploadedAt: result.syncedAt,
            ),
          );
          completed++;
        } else {
          await _handleSyncFailure(item, result.error ?? 'Unknown error');
          failed++;
        }
      } catch (e) {
        await _handleSyncFailure(item, e.toString());
        failed++;
      }

      inProgress--;
      _emitProgress(total, completed, failed, inProgress);

      // Small delay between items to prevent overwhelming the server
      if (_syncStrategy == SyncStrategy.batched) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  Future<SyncResult> _syncSingleItem(SyncItem item) async {
    try {
      // Check if there's a custom handler for this entity type
      final handler = _syncHandlers[item.entityType];
      if (handler != null) {
        return await handler.sync(item);
      }

      // Default sync implementation
      return await _defaultSync(item);
    } catch (e) {
      return SyncResult.failure('Sync failed: $e');
    }
  }

  Future<SyncResult> _defaultSync(SyncItem item) async {
    try {
      final endpoint = item.endpoint ?? '/api/${item.entityType.toLowerCase()}s';

      final response = await dio.post(
        endpoint,
        data: item.data,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SyncResult.success(responseData: response.data);
      } else {
        return SyncResult.failure('HTTP ${response.statusCode}: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (SyncUtils.isRetryableError(Exception(e.toString()))) {
        return SyncResult.failure('Network error: ${e.message}');
      } else {
        return SyncResult.failure('Non-retryable error: ${e.message}');
      }
    } catch (e) {
      return SyncResult.failure('Unexpected error: $e');
    }
  }

  Future<void> _handleSyncFailure(SyncItem item, String error) async {
    final newRetryCount = item.status.retryCount + 1;
    final canRetry = _retryPolicy.shouldRetry(newRetryCount, Exception(error));

    UploadStatus newStatus;
    if (canRetry) {
      final delay = _retryPolicy.calculateDelay(newRetryCount);
      newStatus = item.status.copyWith(
        state: UploadState.failed,
        error: error,
        retryCount: newRetryCount,
        nextRetryAt: DateTime.now().add(delay),
      );
    } else {
      newStatus = item.status.copyWith(
        state: UploadState.failed,
        error: error,
        retryCount: newRetryCount,
      );
    }

    await _updateSyncItemStatus(item.id, newStatus);
  }

  Future<void> _updateSyncItemStatus(String syncItemId, UploadStatus status) async {
    try {
      await database.customUpdate(
        'UPDATE sync_items SET status = ?, last_attempt_at = ? WHERE id = ?',
        variables: [
          Variable.withString(jsonEncode(status.toJson())),
          Variable.withDateTime(DateTime.now()),
          Variable.withString(syncItemId),
        ],
      );

      await _updateQueueStream();
    } catch (e) {
      throw DatabaseException(
        'Failed to update sync item status: $e',
        tableName: 'sync_items',
        operation: 'update',
      );
    }
  }

  Future<SyncItem?> _getSyncItemById(String syncItemId) async {
    try {
      final result = await database.customSelect(
        'SELECT * FROM sync_items WHERE id = ?',
        variables: [Variable.withString(syncItemId)],
      ).getSingleOrNull();

      return result != null ? _convertRowToSyncItem(result.data) : null;
    } catch (e) {
      throw DatabaseException(
        'Failed to get sync item by ID: $e',
        tableName: 'sync_items',
        operation: 'select',
      );
    }
  }

  SyncItem _convertRowToSyncItem(Map<String, dynamic> data) {
    try {
      final statusJson = jsonDecode(data['status'] as String) as Map<String, dynamic>;
      final dependencies = jsonDecode(data['dependencies'] as String) as List<dynamic>;

      return SyncItem(
        id: data['id'] as String,
        entityType: data['entity_type'] as String,
        entityId: data['entity_id'] as String,
        data: jsonDecode(data['data'] as String) as Map<String, dynamic>,
        createdAt: DateTime.parse(data['created_at'] as String),
        status: UploadStatus.fromJson(statusJson),
        priority: SyncPriority.values.firstWhere(
          (p) => p.value == data['priority'] as int,
          orElse: () => SyncPriority.normal,
        ),
        endpoint: data['endpoint'] as String?,
        lastAttemptAt: data['last_attempt_at'] != null ? DateTime.parse(data['last_attempt_at'] as String) : null,
        dependencies: dependencies.cast<String>(),
      );
    } catch (e) {
      throw SerializationException(
        'Failed to convert sync item data: $e',
        operation: 'deserialize',
      );
    }
  }

  void _emitProgress(int total, int completed, int failed, int inProgress) {
    final progress = SyncProgress(
      total: total,
      completed: completed,
      failed: failed,
      inProgress: inProgress,
    );
    _progressController.add(progress);
  }

  Future<void> _updateQueueStream() async {
    try {
      final currentQueue = await getSyncQueue();
      _queueController.add(currentQueue);
    } catch (e) {
      // Log error but don't throw to prevent breaking the stream
      debugPrint('Error updating queue stream: $e');
    }
  }
}

// Helper function for debugging prints
void debugPrint(String message) {
  if (const bool.fromEnvironment('dart.vm.product')) {
    // Don't print in production
    return;
  }
  // ignore: avoid_print
  print(message);
}
