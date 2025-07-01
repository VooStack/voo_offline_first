import 'package:equatable/equatable.dart';
import 'package:voo_offline_first/src/core/models/sync_progress.dart';
import 'package:voo_offline_first/voo_offline_first.dart';

/// Base class for all sync states
abstract class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object?> get props => [];
}

/// Initial state before sync system is initialized
class SyncInitial extends SyncState {
  const SyncInitial();
}

/// State when sync system is being initialized
class SyncInitializing extends SyncState {
  const SyncInitializing();
}

/// State when sync system is ready and idle
class SyncIdle extends SyncState {
  const SyncIdle({
    required this.isConnected,
    required this.autoSyncEnabled,
    required this.syncQueue,
    required this.progress,
  });

  final bool isConnected;
  final bool autoSyncEnabled;
  final List<SyncItem> syncQueue;
  final SyncProgress progress;

  @override
  List<Object?> get props => [isConnected, autoSyncEnabled, syncQueue, progress];

  SyncIdle copyWith({
    bool? isConnected,
    bool? autoSyncEnabled,
    List<SyncItem>? syncQueue,
    SyncProgress? progress,
  }) {
    return SyncIdle(
      isConnected: isConnected ?? this.isConnected,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      syncQueue: syncQueue ?? this.syncQueue,
      progress: progress ?? this.progress,
    );
  }
}

/// State when sync is actively running
class SyncInProgress extends SyncState {
  const SyncInProgress({
    required this.isConnected,
    required this.autoSyncEnabled,
    required this.syncQueue,
    required this.progress,
    this.currentItem,
  });

  final bool isConnected;
  final bool autoSyncEnabled;
  final List<SyncItem> syncQueue;
  final SyncProgress progress;
  final SyncItem? currentItem;

  @override
  List<Object?> get props => [
        isConnected,
        autoSyncEnabled,
        syncQueue,
        progress,
        currentItem,
      ];

  SyncInProgress copyWith({
    bool? isConnected,
    bool? autoSyncEnabled,
    List<SyncItem>? syncQueue,
    SyncProgress? progress,
    SyncItem? currentItem,
  }) {
    return SyncInProgress(
      isConnected: isConnected ?? this.isConnected,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      syncQueue: syncQueue ?? this.syncQueue,
      progress: progress ?? this.progress,
      currentItem: currentItem ?? this.currentItem,
    );
  }
}

/// State when sync is paused (usually due to lack of connectivity)
class SyncPaused extends SyncState {
  const SyncPaused({
    required this.isConnected,
    required this.autoSyncEnabled,
    required this.syncQueue,
    required this.progress,
    this.reason,
  });

  final bool isConnected;
  final bool autoSyncEnabled;
  final List<SyncItem> syncQueue;
  final SyncProgress progress;
  final String? reason;

  @override
  List<Object?> get props => [
        isConnected,
        autoSyncEnabled,
        syncQueue,
        progress,
        reason,
      ];

  SyncPaused copyWith({
    bool? isConnected,
    bool? autoSyncEnabled,
    List<SyncItem>? syncQueue,
    SyncProgress? progress,
    String? reason,
  }) {
    return SyncPaused(
      isConnected: isConnected ?? this.isConnected,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      syncQueue: syncQueue ?? this.syncQueue,
      progress: progress ?? this.progress,
      reason: reason ?? this.reason,
    );
  }
}

/// State when there's an error with the sync system
class SyncError extends SyncState {
  const SyncError({
    required this.isConnected,
    required this.autoSyncEnabled,
    required this.syncQueue,
    required this.progress,
    required this.error,
    this.stackTrace,
  });

  final bool isConnected;
  final bool autoSyncEnabled;
  final List<SyncItem> syncQueue;
  final SyncProgress progress;
  final String error;
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [
        isConnected,
        autoSyncEnabled,
        syncQueue,
        progress,
        error,
        stackTrace,
      ];

  SyncError copyWith({
    bool? isConnected,
    bool? autoSyncEnabled,
    List<SyncItem>? syncQueue,
    SyncProgress? progress,
    String? error,
    StackTrace? stackTrace,
  }) {
    return SyncError(
      isConnected: isConnected ?? this.isConnected,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      syncQueue: syncQueue ?? this.syncQueue,
      progress: progress ?? this.progress,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }
}

/// State when an operation completed successfully
class SyncSuccess extends SyncState {
  const SyncSuccess({
    required this.isConnected,
    required this.autoSyncEnabled,
    required this.syncQueue,
    required this.progress,
    this.message,
  });

  final bool isConnected;
  final bool autoSyncEnabled;
  final List<SyncItem> syncQueue;
  final SyncProgress progress;
  final String? message;

  @override
  List<Object?> get props => [
        isConnected,
        autoSyncEnabled,
        syncQueue,
        progress,
        message,
      ];

  SyncSuccess copyWith({
    bool? isConnected,
    bool? autoSyncEnabled,
    List<SyncItem>? syncQueue,
    SyncProgress? progress,
    String? message,
  }) {
    return SyncSuccess(
      isConnected: isConnected ?? this.isConnected,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      syncQueue: syncQueue ?? this.syncQueue,
      progress: progress ?? this.progress,
      message: message ?? this.message,
    );
  }
}

/// Sync status enum (from sync_manager interface)
enum SyncStatus {
  idle,
  syncing,
  paused,
  error,
}
