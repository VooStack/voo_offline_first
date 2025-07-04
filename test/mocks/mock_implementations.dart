import 'dart:async';
import 'package:voo_offline_first/src/core/models/sync_progress.dart';
import 'package:voo_offline_first/voo_offline_first.dart';

/// Mock implementation of SyncManager for testing
class MockSyncManagerImpl implements SyncManager {
  final Map<String, SyncItem> _syncQueue = {};
  StreamController<List<SyncItem>>? _queueController;
  StreamController<SyncStatus>? _statusController;
  StreamController<SyncProgress>? _progressController;

  bool _isInitialized = false;
  bool _autoSyncEnabled = false;
  bool _isDisposed = false;
  SyncStatus _currentStatus = SyncStatus.idle;
  Timer? _autoSyncTimer;

  // Track sync operations for testing
  final List<SyncItem> syncedItems = [];
  final List<String> cancelledItems = [];
  final List<String> retriedItems = [];

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    _queueController = StreamController.broadcast();
    _statusController = StreamController.broadcast();
    _progressController = StreamController.broadcast();

    _isInitialized = true;
    _currentStatus = SyncStatus.idle;
    _safeAddToStatusController(_currentStatus);
  }

  @override
  Future<void> queueForSync(SyncItem item) async {
    _ensureInitialized();
    _syncQueue[item.id] = item;
    _safeEmitQueueUpdate();

    // Trigger auto-sync if enabled
    if (_autoSyncEnabled && !_isDisposed) {
      _scheduleAutoSync();
    }
  }

  @override
  Future<void> queueMultipleForSync(List<SyncItem> items) async {
    _ensureInitialized();
    for (final item in items) {
      _syncQueue[item.id] = item;
    }
    _safeEmitQueueUpdate();

    // Trigger auto-sync if enabled
    if (_autoSyncEnabled && !_isDisposed) {
      _scheduleAutoSync();
    }
  }

  @override
  Future<void> startAutoSync() async {
    _ensureInitialized();
    _autoSyncEnabled = true;

    // Trigger immediate sync if there are pending items
    final pendingItems = _syncQueue.values.where((item) => item.status.isPending).toList();
    if (pendingItems.isNotEmpty && !_isDisposed) {
      _scheduleAutoSync();
    }
  }

  @override
  Future<void> stopAutoSync() async {
    _ensureInitialized();
    _autoSyncEnabled = false;
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }

  @override
  Future<void> syncNow() async {
    _ensureInitialized();
    if (_isDisposed) return;

    if (_currentStatus == SyncStatus.syncing) return;

    _currentStatus = SyncStatus.syncing;
    _safeAddToStatusController(_currentStatus);

    final pendingItems = _syncQueue.values.where((item) => item.status.isPending).toList();

    if (pendingItems.isEmpty) {
      _currentStatus = SyncStatus.idle;
      _safeAddToStatusController(_currentStatus);
      return;
    }

    try {
      // Simulate sync progress
      for (int i = 0; i < pendingItems.length; i++) {
        if (_isDisposed) break;

        final item = pendingItems[i];

        _safeAddToProgressController(
          SyncProgress(
            total: pendingItems.length,
            completed: i,
            failed: 0,
            inProgress: 1,
          ),
        );

        // Update item status to uploading
        _syncQueue[item.id] = item.copyWith(
          status: item.status.copyWith(state: UploadState.uploading),
        );
        _safeEmitQueueUpdate();

        // Simulate upload time
        await Future.delayed(const Duration(milliseconds: 10));
        if (_isDisposed) break;

        // Mark as completed (for simplicity, all items succeed in mock)
        _syncQueue[item.id] = item.copyWith(
          status: item.status.copyWith(
            state: UploadState.completed,
            uploadedAt: DateTime.now(),
          ),
        );
        syncedItems.add(item);
        _safeEmitQueueUpdate();
      }

      if (!_isDisposed) {
        _safeAddToProgressController(
          SyncProgress(
            total: pendingItems.length,
            completed: pendingItems.length,
            failed: 0,
            inProgress: 0,
          ),
        );

        _currentStatus = SyncStatus.idle;
        _safeAddToStatusController(_currentStatus);
      }
    } catch (e) {
      if (!_isDisposed) {
        _currentStatus = SyncStatus.error;
        _safeAddToStatusController(_currentStatus);
      }
    }
  }

  @override
  Future<void> retryFailed() async {
    _ensureInitialized();

    final failedItems = _syncQueue.values.where((item) => item.status.isFailed).toList();

    for (final item in failedItems) {
      _syncQueue[item.id] = item.copyWith(
        status: item.status.copyWith(state: UploadState.pending),
      );
      retriedItems.add(item.id);
    }

    _safeEmitQueueUpdate();
  }

  @override
  Future<SyncResult> retrySyncItem(String syncItemId) async {
    _ensureInitialized();

    final item = _syncQueue[syncItemId];
    if (item == null) {
      return SyncResult.failure('Item not found');
    }

    if (!item.status.canRetry) {
      return SyncResult.failure('Cannot retry item');
    }

    _syncQueue[syncItemId] = item.copyWith(
      status: item.status.copyWith(state: UploadState.pending),
    );
    retriedItems.add(syncItemId);
    _safeEmitQueueUpdate();

    return SyncResult.success();
  }

  @override
  Future<void> cancelSyncItem(String syncItemId) async {
    _ensureInitialized();

    final item = _syncQueue[syncItemId];
    if (item != null) {
      _syncQueue[syncItemId] = item.copyWith(
        status: item.status.copyWith(state: UploadState.cancelled),
      );
      cancelledItems.add(syncItemId);
      _safeEmitQueueUpdate();
    }
  }

  @override
  Future<void> clearCompleted() async {
    _ensureInitialized();

    _syncQueue.removeWhere((_, item) => item.status.isCompleted);
    _safeEmitQueueUpdate();
  }

  @override
  Future<List<SyncItem>> getSyncQueue() async {
    _ensureInitialized();
    return _syncQueue.values.toList();
  }

  @override
  Future<List<SyncItem>> getSyncQueueByStatus(List<UploadState> states) async {
    _ensureInitialized();
    return _syncQueue.values.where((item) => states.contains(item.status.state)).toList();
  }

  @override
  Future<SyncStatistics> getSyncStatistics() async {
    _ensureInitialized();

    final allItems = _syncQueue.values.toList();
    final completed = allItems.where((item) => item.status.isCompleted);
    final failed = allItems.where((item) => item.status.isFailed);

    return SyncStatistics(
      totalSynced: completed.length,
      totalFailed: failed.length,
      averageSyncTime: const Duration(seconds: 2),
      lastSyncAt: completed.isNotEmpty ? DateTime.now() : null,
    );
  }

  @override
  Stream<List<SyncItem>> watchSyncQueue() {
    _ensureInitialized();
    return _queueController!.stream;
  }

  @override
  Stream<SyncStatus> watchSyncStatus() {
    _ensureInitialized();
    return _statusController!.stream;
  }

  @override
  Stream<SyncProgress> watchSyncProgress() {
    _ensureInitialized();
    return _progressController!.stream;
  }

  @override
  void setSyncStrategy(SyncStrategy strategy) {
    // Mock implementation - just store the strategy
  }

  @override
  void registerSyncHandler(String entityType, SyncHandler handler) {
    // Mock implementation - could store handlers in a map if needed
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;

    _isDisposed = true;
    _autoSyncEnabled = false;
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;

    await _queueController?.close();
    await _statusController?.close();
    await _progressController?.close();

    _queueController = null;
    _statusController = null;
    _progressController = null;
    _isInitialized = false;
  }

  void _ensureInitialized() {
    if (!_isInitialized || _isDisposed) {
      throw Exception('MockSyncManager not initialized or disposed');
    }
  }

  void _safeEmitQueueUpdate() {
    if (!_isDisposed && _queueController != null && !_queueController!.isClosed) {
      _queueController!.add(_syncQueue.values.toList());
    }
  }

  void _safeAddToStatusController(SyncStatus status) {
    if (!_isDisposed && _statusController != null && !_statusController!.isClosed) {
      _statusController!.add(status);
    }
  }

  void _safeAddToProgressController(SyncProgress progress) {
    if (!_isDisposed && _progressController != null && !_progressController!.isClosed) {
      _progressController!.add(progress);
    }
  }

  void _scheduleAutoSync() {
    if (_isDisposed) return;

    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer(const Duration(milliseconds: 50), () {
      if (_autoSyncEnabled && !_isDisposed && _syncQueue.values.any((item) => item.status.isPending)) {
        syncNow();
      }
    });
  }

  // Helper methods for testing
  void simulateFailedItem(String syncItemId, String error) {
    if (_isDisposed) return;

    final item = _syncQueue[syncItemId];
    if (item != null) {
      _syncQueue[syncItemId] = item.copyWith(
        status: item.status.copyWith(
          state: UploadState.failed,
          error: error,
          retryCount: item.status.retryCount + 1,
        ),
      );
      _safeEmitQueueUpdate();
    }
  }

  void simulateError() {
    if (_isDisposed) return;

    _currentStatus = SyncStatus.error;
    _safeAddToStatusController(_currentStatus);
  }

  void reset() {
    _syncQueue.clear();
    syncedItems.clear();
    cancelledItems.clear();
    retriedItems.clear();
    _autoSyncEnabled = false;
    _currentStatus = SyncStatus.idle;
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }
}

/// Mock implementation of ConnectivityService for testing
class MockConnectivityServiceImpl implements ConnectivityService {
  final StreamController<bool> _connectivityController = StreamController.broadcast();
  final StreamController<ConnectionType> _connectionTypeController = StreamController.broadcast();
  final StreamController<ConnectionQuality> _qualityController = StreamController.broadcast();

  bool _isInitialized = false;
  bool _isConnected = true;
  ConnectionType _connectionType = ConnectionType.wifi;
  ConnectionQuality _quality = ConnectionQuality.good;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  Future<bool> isConnected() async {
    _ensureInitialized();
    return _isConnected;
  }

  @override
  Future<ConnectionType> getConnectionType() async {
    _ensureInitialized();
    return _connectionType;
  }

  @override
  Future<bool> canReachHost(String host) async {
    _ensureInitialized();
    return _isConnected;
  }

  @override
  Stream<bool> watchConnectivity() {
    return _connectivityController.stream;
  }

  @override
  Stream<ConnectionType> watchConnectionType() {
    return _connectionTypeController.stream;
  }

  @override
  Future<ConnectionQuality> getConnectionQuality() async {
    _ensureInitialized();
    return _quality;
  }

  @override
  Stream<ConnectionQuality> watchConnectionQuality() {
    return _qualityController.stream;
  }

  @override
  Future<void> dispose() async {
    await _connectivityController.close();
    await _connectionTypeController.close();
    await _qualityController.close();
    _isInitialized = false;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception('MockConnectivityService not initialized');
    }
  }

  // Helper methods for testing
  void setConnected(bool connected) {
    _isConnected = connected;
    _connectivityController.add(connected);
  }

  void setConnectionType(ConnectionType type) {
    _connectionType = type;
    _connectionTypeController.add(type);
  }

  void setConnectionQuality(ConnectionQuality quality) {
    _quality = quality;
    _qualityController.add(quality);
  }

  void simulateConnectivityChange(bool connected) {
    setConnected(connected);
  }

  void reset() {
    _isConnected = true;
    _connectionType = ConnectionType.wifi;
    _quality = ConnectionQuality.good;
  }
}

/// Mock implementation of OfflineRepository for testing
class MockOfflineRepository<T> implements OfflineRepository<T> {
  MockOfflineRepository({
    required String Function(T) getId,
    required T Function(T, String) setId,
    required Map<String, dynamic> Function(T) toJson,
    required T Function(Map<String, dynamic>) fromJson,
  })  : _getId = getId,
        _setId = setId,
        _toJson = toJson,
        _fromJson = fromJson;
  final Map<String, T> _storage = {};
  final Map<String, UploadStatus> _uploadStatuses = {};
  final Set<String> _pendingSyncItems = {};

  final StreamController<List<T>> _allItemsController = StreamController.broadcast();
  final StreamController<List<SyncItem>> _pendingSyncController = StreamController.broadcast();
  final StreamController<UploadStatus?> _uploadStatusController = StreamController.broadcast();

  final String Function(T) _getId;
  final T Function(T, String) _setId;
  final Map<String, dynamic> Function(T) _toJson;
  final T Function(Map<String, dynamic>) _fromJson;

  @override
  Future<List<T>> getAll() async {
    return _storage.values.toList();
  }

  @override
  Future<List<T>> getWhere(Map<String, dynamic> criteria) async {
    // Simple mock implementation - just return all items
    return getAll();
  }

  @override
  Future<T?> getById(String id) async {
    return _storage[id];
  }

  @override
  Future<T> save(T entity) async {
    final id = _getId(entity);
    final entityWithId = id.isEmpty ? _setId(entity, 'mock-id-${DateTime.now().millisecondsSinceEpoch}') : entity;
    final finalId = _getId(entityWithId);

    _storage[finalId] = entityWithId;
    _uploadStatuses[finalId] = const UploadStatus(state: UploadState.pending);
    _pendingSyncItems.add(finalId);

    _emitUpdates();
    return entityWithId;
  }

  @override
  Future<List<T>> saveAll(List<T> entities) async {
    final savedEntities = <T>[];

    // Process each entity sequentially to ensure proper ID generation
    for (final entity in entities) {
      final id = _getId(entity);
      final entityWithId = id.isEmpty ? _setId(entity, 'mock-id-${DateTime.now().millisecondsSinceEpoch}-${savedEntities.length}') : entity;
      final finalId = _getId(entityWithId);

      _storage[finalId] = entityWithId;
      _uploadStatuses[finalId] = const UploadStatus(state: UploadState.pending);
      _pendingSyncItems.add(finalId);

      savedEntities.add(entityWithId);

      // Small delay to ensure unique timestamps
      await Future.delayed(const Duration(microseconds: 1));
    }

    _emitUpdates();
    return savedEntities;
  }

  @override
  Future<void> delete(String id) async {
    _storage.remove(id);
    _uploadStatuses.remove(id);
    _pendingSyncItems.remove(id);
    _emitUpdates();
  }

  @override
  Future<void> deleteAll(List<String> ids) async {
    for (final id in ids) {
      await delete(id);
    }
  }

  @override
  Future<List<T>> getPendingSync() async {
    return _pendingSyncItems.map((id) => _storage[id]).where((item) => item != null).cast<T>().toList();
  }

  @override
  Future<void> markAsUploaded(String id) async {
    _uploadStatuses[id] = const UploadStatus(state: UploadState.completed);
    _pendingSyncItems.remove(id);
    _emitUpdates();
  }

  @override
  Future<void> updateUploadStatus(String id, UploadStatus status) async {
    _uploadStatuses[id] = status;
    if (status.isCompleted) {
      _pendingSyncItems.remove(id);
    } else if (status.isPending || status.isFailed) {
      _pendingSyncItems.add(id);
    }
    _emitUpdates();
  }

  @override
  Future<void> queueForSync(String id) async {
    _pendingSyncItems.add(id);
    _uploadStatuses[id] = const UploadStatus(state: UploadState.pending);
    _emitUpdates();
  }

  @override
  Future<void> removeFromSyncQueue(String id) async {
    _pendingSyncItems.remove(id);
    _emitUpdates();
  }

  @override
  Stream<List<T>> watchAll() {
    return _allItemsController.stream;
  }

  @override
  Stream<List<T>> watchWhere(Map<String, dynamic> criteria) {
    return watchAll();
  }

  @override
  Stream<List<SyncItem>> watchPendingSync() {
    return _pendingSyncController.stream;
  }

  @override
  Stream<UploadStatus?> watchUploadStatus(String id) {
    return _uploadStatusController.stream.map((_) => _uploadStatuses[id]);
  }

  @override
  Future<int> count() async {
    return _storage.length;
  }

  @override
  Future<int> countPendingSync() async {
    return _pendingSyncItems.length;
  }

  @override
  Future<void> clear() async {
    _storage.clear();
    _uploadStatuses.clear();
    _pendingSyncItems.clear();
    _emitUpdates();
  }

  void _emitUpdates() {
    _allItemsController.add(_storage.values.toList());

    final pendingSyncItems = _pendingSyncItems
        .map((id) {
          final entity = _storage[id];
          if (entity == null) return null;

          return SyncItem(
            id: 'sync_$id',
            entityType: 'MockEntity',
            entityId: id,
            data: _toJson(entity),
            createdAt: DateTime.now(),
            status: _uploadStatuses[id] ?? const UploadStatus(state: UploadState.pending),
            priority: SyncPriority.normal,
          );
        })
        .where((item) => item != null)
        .cast<SyncItem>()
        .toList();

    _pendingSyncController.add(pendingSyncItems);
    _uploadStatusController.add(null); // Trigger stream update
  }

  Future<void> dispose() async {
    await _allItemsController.close();
    await _pendingSyncController.close();
    await _uploadStatusController.close();
  }

  // Helper methods for testing
  void reset() {
    _storage.clear();
    _uploadStatuses.clear();
    _pendingSyncItems.clear();
  }

  Map<String, T> get storage => Map.unmodifiable(_storage);
  Map<String, UploadStatus> get uploadStatuses => Map.unmodifiable(_uploadStatuses);
  Set<String> get pendingSyncItems => Set.unmodifiable(_pendingSyncItems);
}

/// Test entity for use in mock repository
class TestEntity {
  factory TestEntity.fromJson(Map<String, dynamic> json) => TestEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
      );
  const TestEntity({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;

  TestEntity copyWith({
    String? id,
    String? name,
    String? description,
  }) {
    return TestEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TestEntity && runtimeType == other.runtimeType && id == other.id && name == other.name && description == other.description;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ description.hashCode;

  @override
  String toString() => 'TestEntity(id: $id, name: $name, description: $description)';
}
