import 'package:equatable/equatable.dart';
import '../core/models/sync_item.dart';

/// Base class for all sync events
abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the sync system
class SyncInitialize extends SyncEvent {
  const SyncInitialize();
}

/// Event to start automatic syncing
class SyncStartAutoSync extends SyncEvent {
  const SyncStartAutoSync();
}

/// Event to stop automatic syncing
class SyncStopAutoSync extends SyncEvent {
  const SyncStopAutoSync();
}

/// Event to manually trigger a sync
class SyncTriggerSync extends SyncEvent {
  const SyncTriggerSync();
}

/// Event to queue an item for sync
class SyncQueueItem extends SyncEvent {
  const SyncQueueItem(this.item);

  final SyncItem item;

  @override
  List<Object?> get props => [item];
}

/// Event to queue multiple items for sync
class SyncQueueMultipleItems extends SyncEvent {
  const SyncQueueMultipleItems(this.items);

  final List<SyncItem> items;

  @override
  List<Object?> get props => [items];
}

/// Event to retry failed sync items
class SyncRetryFailed extends SyncEvent {
  const SyncRetryFailed();
}

/// Event to retry a specific sync item
class SyncRetryItem extends SyncEvent {
  const SyncRetryItem(this.syncItemId);

  final String syncItemId;

  @override
  List<Object?> get props => [syncItemId];
}

/// Event to cancel a sync item
class SyncCancelItem extends SyncEvent {
  const SyncCancelItem(this.syncItemId);

  final String syncItemId;

  @override
  List<Object?> get props => [syncItemId];
}

/// Event to clear completed sync items
class SyncClearCompleted extends SyncEvent {
  const SyncClearCompleted();
}

/// Event when connectivity status changes
class SyncConnectivityChanged extends SyncEvent {
  const SyncConnectivityChanged(this.isConnected);

  final bool isConnected;

  @override
  List<Object?> get props => [isConnected];
}

/// Event when sync queue is updated
class SyncQueueUpdated extends SyncEvent {
  const SyncQueueUpdated(this.syncItems);

  final List<SyncItem> syncItems;

  @override
  List<Object?> get props => [syncItems];
}

/// Event when sync status changes
class SyncStatusChanged extends SyncEvent {
  const SyncStatusChanged(this.status);

  final SyncStatus status;

  @override
  List<Object?> get props => [status];
}

/// Event when sync progress updates
class SyncProgressUpdated extends SyncEvent {
  const SyncProgressUpdated(this.progress);

  final SyncProgress progress;

  @override
  List<Object?> get props => [progress];
}

/// Sync status enum (from sync_manager interface)
enum SyncStatus {
  idle,
  syncing,
  paused,
  error,
}

/// Sync progress model (from sync_manager interface)
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
