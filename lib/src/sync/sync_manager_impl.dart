import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../core/interfaces/sync_manager.dart';
import '../core/interfaces/connectivity_service.dart';
import '../core/models/sync_item.dart';
import '../core/models/sync_result.dart';
import '../core/models/upload_status.dart';
import '../database/sync_database.dart';
import '../database/tables.dart';
import '../utils/retry_policy.dart';
import '../annotations/offline_entity.dart';

/// Implementation of SyncManager that handles sync operations
class SyncManagerImpl implements SyncManager {
  SyncManagerImpl({
    required this.database,
    required this.connectivityService,
    required this.dio,
    this.retryPolicy,
  }) : _retryPolicy = retryPolicy ?? ExponentialBackoffRetryPolicy();

  final SyncDatabase database;
  final ConnectivityService connectivityService;
  final Dio dio;
  final RetryPolicy _retryPolicy;

  final Map<String, SyncHandler> _syncHandlers = {};
  final StreamController<SyncStatus> _statusController = StreamController.broadcast();
  final StreamController<SyncProgress> _progressController = StreamController.broadcast();

  StreamSubscription? _connectivitySubscription;
  SyncStrategy _syncStrategy = SyncStrategy.immediate;
  bool _isInitialized = false;
  bool _isSyncing = false;
  bool _autoSyncEnabled = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Listen to connectivity changes
    _connectivitySubscription = connectivityService.watchConnectivity().listen(
      (isConnected) {
        if (isConnected && _autoSyncEnabled && !_isSyncing) {
          _triggerSync();
        }
      },
    );

    _isInitialized = true;
  }

  @override
  Future<void> queueForSync(SyncItem item) async {
    final companion = SyncItemsCompanion(
      id: Value(item.id),
      entityType: Value(item.entityType),
      entityId: Value(item.entityId),
      data: Value(jsonEncode(item.data)),
      createdAt: Value(item.createdAt),
      status: Value(jsonEncode(item.status.toJson())),
      priority: Value(item.priority.value),
      endpoint: Value.absentIfNull(item.endpoint),
      lastAttemptAt: Value.absentIfNull(item.lastAttemptAt),
      dependencies: Value(jsonEncode(item.dependencies)),
    );

    await database.insertSyncItem(companion);

    // Trigger sync if auto-sync is enabled and we're connected
    if (_autoSyncEnabled && await connectivityService.isConnected()) {
      _triggerSync();
    }
  }

  @override
  Future<void> queueMultipleForSync(List<SyncItem> items) async {
    for (final item in items) {
      await queueForSync(item);
    }
  }

  @override
  Future<void> startAutoSync() async {
    _autoSyncEnabled = true;

    if (await connectivityService.isConnected()) {
      await syncNow();
    }
  }

  @override
  Future<void> stopAutoSync() async {
    _autoSyncEnabled = false;
  }

  @override
  Future<void> syncNow() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _statusController.add(SyncStatus.syncing);

    try {
      final pendingItems = await _getPendingSyncItems();
      await _processSyncItems(pendingItems);

      _statusController.add(SyncStatus.idle);
    } catch (e) {
      _statusController.add(SyncStatus.error);
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }

  @override
  Future<void> retryFailed() async {
    final failedItems = await database.getSyncQueueByStatus([UploadState.failed]);

    for (final itemData in failedItems) {
      final item = _syncItemDataToSyncItem(itemData);
      if (item.shouldRetry) {
        await retrySyncItem(item.id);
      }
    }
  }

  @override
  Future<SyncResult> retrySyncItem(String syncItemId) async {
    final itemData = await database.getSyncItemById(syncItemId);
    if (itemData == null) {
      return SyncResult.failure('Sync item not found');
    }

    final item = _syncItemDataToSyncItem(itemData);
    return await _syncSingleItem(item);
  }

  @override
  Future<void> cancelSyncItem(String syncItemId) async {
    await database.deleteSyncItem(syncItemId);
  }

  @override
  Future<void> clearCompleted() async {
    await database.clearCompletedSyncItems();
  }

  @override
  Future<List<SyncItem>> getSyncQueue() async {
    final items = await database.getAllSyncItems();
    return items.map(_syncItemDataToSyncItem).toList();
  }

  @override
  Future<List<SyncItem>> getSyncQueueByStatus(List<UploadState> states) async {
    final allItems = await database.getAllSyncItems();
    return allItems
        .where((item) {
          final status = UploadStatus.fromJson(jsonDecode(item.status));
          return states.contains(status.state);
        })
        .map(_syncItemDataToSyncItem)
        .toList();
  }

  @override
  Future<SyncStatistics> getSyncStatistics() async {
    // This is a simplified implementation
    // You might want to store more detailed statistics in the database
    final allItems = await database.getAllSyncItems();
    final completed = allItems.where((item) {
      final status = UploadStatus.fromJson(jsonDecode(item.status));
      return status.isCompleted;
    }).length;

    final failed = allItems.where((item) {
      final status = UploadStatus.fromJson(jsonDecode(item.status));
      return status.isFailed;
    }).length;

    return SyncStatistics(
      totalSynced: completed,
      totalFailed: failed,
      averageSyncTime: const Duration(seconds: 30), // Placeholder
      lastSyncAt: DateTime.now(), // Placeholder
    );
  }

  @override
  Stream<List<SyncItem>> watchSyncQueue() {
    return database.watchSyncItems().map((items) => items.map(_syncItemDataToSyncItem).toList());
  }

  @override
  Stream<SyncStatus> watchSyncStatus() {
    return _statusController.stream;
  }

  @override
  Stream<SyncProgress> watchSyncProgress() {
    return _progressController.stream;
  }

  @override
  void setSyncStrategy(SyncStrategy strategy) {
    _syncStrategy = strategy;
  }

  @override
  void registerSyncHandler(String entityType, SyncHandler handler) {
    _syncHandlers[entityType] = handler;
  }

  @override
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _statusController.close();
    await _progressController.close();
  }

  // Private helper methods

  void _triggerSync() {
    // Use a timer to prevent rapid successive sync triggers
    Timer(const Duration(seconds: 1), () {
      if (!_isSyncing && _autoSyncEnabled) {
        syncNow();
      }
    });
  }

  Future<List<SyncItem>> _getPendingSyncItems() async {
    final items = await database.getPendingSyncItems();
    return items.map(_syncItemDataToSyncItem).where((item) => item.isReadyForSync).toList()..sort((a, b) => b.priority.value.compareTo(a.priority.value));
  }

  Future<void> _processSyncItems(List<SyncItem> items) async {
    if (items.isEmpty) return;

    _progressController.add(SyncProgress(
      total: items.length,
      completed: 0,
      failed: 0,
      inProgress: 0,
    ));

    int completed = 0;
    int failed = 0;

    for (final item in items) {
      if (!await connectivityService.isConnected()) {
        break; // Stop syncing if connectivity is lost
      }

      _progressController.add(SyncProgress(
        total: items.length,
        completed: completed,
        failed: failed,
        inProgress: 1,
      ));

      final result = await _syncSingleItem(item);

      if (result.success) {
        completed++;
      } else {
        failed++;
      }

      _progressController.add(SyncProgress(
        total: items.length,
        completed: completed,
        failed: failed,
        inProgress: 0,
      ));
    }
  }

  Future<SyncResult> _syncSingleItem(SyncItem item) async {
    try {
      // Update status to uploading
      await _updateSyncItemStatus(
        item.id,
        item.status.copyWith(
          state: UploadState.uploading,
          progress: 0.0,
        ),
      );

      // Check if there's a custom sync handler
      final handler = _syncHandlers[item.entityType];
      if (handler != null) {
        return await handler.sync(item);
      }

      // Default sync implementation
      return await _defaultSync(item);
    } catch (e) {
      final failureStatus = item.status.copyWith(
        state: UploadState.failed,
        error: e.toString(),
        progress: 0.0,
      );

      await _updateSyncItemStatus(item.id, failureStatus);
      return SyncResult.failure(e.toString());
    }
  }

  Future<SyncResult> _defaultSync(SyncItem item) async {
    final endpoint = item.endpoint ?? _getDefaultEndpoint(item.entityType);
    if (endpoint == null) {
      throw Exception('No endpoint configured for ${item.entityType}');
    }

    final response = await dio.post(
      endpoint,
      data: item.data,
      onSendProgress: (sent, total) {
        if (total > 0) {
          final progress = sent / total;
          _updateSyncItemStatus(
            item.id,
            item.status.copyWith(
              state: UploadState.uploading,
              progress: progress,
            ),
          );
        }
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Success
      await _updateSyncItemStatus(
        item.id,
        item.status.copyWith(
          state: UploadState.completed,
          progress: 1.0,
          uploadedAt: DateTime.now(),
        ),
      );

      return SyncResult.success(responseData: response.data);
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.statusMessage}');
    }
  }

  Future<void> _updateSyncItemStatus(String syncItemId, UploadStatus status) async {
    final companion = SyncItemsCompanion(
      id: Value(syncItemId),
      status: Value(jsonEncode(status.toJson())),
      lastAttemptAt: Value(DateTime.now()),
    );

    await database.updateSyncItem(companion);
  }

  String? _getDefaultEndpoint(String entityType) {
    // This would typically be configured somewhere
    // For now, return a default pattern
    return '/api/${entityType.toLowerCase()}s';
  }

  SyncItem _syncItemDataToSyncItem(SyncItemData data) {
    return SyncItem(
      id: data.id,
      entityType: data.entityType,
      entityId: data.entityId,
      data: jsonDecode(data.data),
      createdAt: data.createdAt,
      status: UploadStatus.fromJson(jsonDecode(data.status)),
      priority: SyncPriority.values.firstWhere(
        (p) => p.value == data.priority,
        orElse: () => SyncPriority.normal,
      ),
      endpoint: data.endpoint,
      lastAttemptAt: data.lastAttemptAt,
      dependencies: List<String>.from(jsonDecode(data.dependencies)),
    );
  }
}
