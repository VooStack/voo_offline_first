import 'package:voo_offline_first/voo_offline_first.dart';

/// Abstract interface for managing sync operations
///
/// The SyncManager is responsible for coordinating all sync activities,
/// managing the sync queue, and handling retry logic.
abstract class SyncManager {
  /// Initialize the sync manager
  Future<void> initialize();

  /// Add an item to the sync queue
  Future<void> queueForSync(SyncItem item);

  /// Add multiple items to the sync queue
  Future<void> queueMultipleForSync(List<SyncItem> items);

  /// Start automatic syncing (when connectivity is available)
  Future<void> startAutoSync();

  /// Stop automatic syncing
  Future<void> stopAutoSync();

  /// Manually trigger a sync operation
  Future<void> syncNow();

  /// Retry all failed sync items
  Future<void> retryFailed();

  /// Retry a specific sync item
  Future<SyncResult> retrySyncItem(String syncItemId);

  /// Cancel a pending sync item
  Future<void> cancelSyncItem(String syncItemId);

  /// Clear all completed sync items from the queue
  Future<void> clearCompleted();

  /// Get all items in the sync queue
  Future<List<SyncItem>> getSyncQueue();

  /// Get items in the sync queue by status
  Future<List<SyncItem>> getSyncQueueByStatus(List<UploadState> states);

  /// Get the current sync statistics
  Future<SyncStatistics> getSyncStatistics();

  /// Watch the sync queue for real-time updates
  Stream<List<SyncItem>> watchSyncQueue();

  /// Watch the overall sync status
  Stream<SyncStatus> watchSyncStatus();

  /// Watch sync progress for real-time updates
  Stream<SyncProgress> watchSyncProgress();

  /// Set the sync strategy (immediate, batched, scheduled)
  void setSyncStrategy(SyncStrategy strategy);

  /// Register a custom sync handler for a specific entity type
  void registerSyncHandler(String entityType, SyncHandler handler);

  /// Dispose of resources
  Future<void> dispose();
}

/// Overall sync status
enum SyncStatus {
  idle,
  syncing,
  paused,
  error,
}

/// Sync strategy options
enum SyncStrategy {
  /// Sync immediately when connectivity is available
  immediate,

  /// Batch sync operations for efficiency
  batched,

  /// Sync on a schedule
  scheduled,
}

/// Sync progress information
class SyncProgress {
  const SyncProgress({
    required this.total,
    required this.completed,
    required this.failed,
    required this.inProgress,
  });

  final int total;
  final int completed;
  final int failed;
  final int inProgress;

  int get pending => total - completed - failed - inProgress;
  double get completionPercentage => total > 0 ? completed / total : 0.0;
}

/// Sync statistics
class SyncStatistics {
  const SyncStatistics({
    required this.totalSynced,
    required this.totalFailed,
    required this.averageSyncTime,
    required this.lastSyncAt,
  });

  final int totalSynced;
  final int totalFailed;
  final Duration averageSyncTime;
  final DateTime? lastSyncAt;
}

/// Custom sync handler interface
abstract class SyncHandler {
  Future<SyncResult> sync(SyncItem item);
}
