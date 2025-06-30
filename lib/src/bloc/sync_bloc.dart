import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voo_offline_first/src/bloc/sync_event.dart';
import 'package:voo_offline_first/voo_offline_first.dart' hide SyncStatus, SyncProgress;

/// BLoC for managing sync operations and state
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  SyncBloc({
    required this.syncManager,
    required this.connectivityService,
  }) : super(const SyncInitial()) {
    // Register event handlers
    on<SyncInitialize>(_onInitialize);
    on<SyncStartAutoSync>(_onStartAutoSync);
    on<SyncStopAutoSync>(_onStopAutoSync);
    on<SyncTriggerSync>(_onTriggerSync);
    on<SyncQueueItem>(_onQueueItem);
    on<SyncQueueMultipleItems>(_onQueueMultipleItems);
    on<SyncRetryFailed>(_onRetryFailed);
    on<SyncRetryItem>(_onRetryItem);
    on<SyncCancelItem>(_onCancelItem);
    on<SyncClearCompleted>(_onClearCompleted);
    on<SyncConnectivityChanged>(_onConnectivityChanged);
    on<SyncQueueUpdated>(_onQueueUpdated);
    on<SyncStatusChanged>(_onStatusChanged);
    on<SyncProgressUpdated>(_onProgressUpdated);
  }

  final SyncManager syncManager;
  final ConnectivityService connectivityService;

  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _syncQueueSubscription;
  StreamSubscription? _syncStatusSubscription;
  StreamSubscription? _syncProgressSubscription;

  List<SyncItem> _currentSyncQueue = [];
  bool _isConnected = false;
  bool _autoSyncEnabled = false;
  SyncProgress _currentProgress = const SyncProgress(
    total: 0,
    completed: 0,
    failed: 0,
    inProgress: 0,
  );

  Future<void> _onInitialize(SyncInitialize event, Emitter<SyncState> emit) async {
    emit(const SyncInitializing());

    try {
      // Initialize services
      await connectivityService.initialize();
      await syncManager.initialize();

      // Check initial connectivity
      _isConnected = await connectivityService.isConnected();

      // Get initial sync queue
      _currentSyncQueue = await syncManager.getSyncQueue();

      // Set up subscriptions
      _connectivitySubscription = connectivityService.watchConnectivity().listen(
            (isConnected) => add(SyncConnectivityChanged(isConnected)),
          );

      _syncQueueSubscription = syncManager.watchSyncQueue().listen(
            (syncItems) => add(SyncQueueUpdated(syncItems)),
          );

      _syncStatusSubscription = syncManager.watchSyncStatus().listen(
            (status) => add(SyncStatusChanged(status as SyncStatus)),
          );

      _syncProgressSubscription = syncManager.watchSyncProgress().listen(
            (progress) => add(SyncProgressUpdated(progress as SyncProgress)),
          );

      emit(
        SyncIdle(
          isConnected: _isConnected,
          autoSyncEnabled: _autoSyncEnabled,
          syncQueue: _currentSyncQueue,
          progress: _currentProgress,
        ),
      );
    } catch (e, stackTrace) {
      emit(
        SyncError(
          isConnected: _isConnected,
          autoSyncEnabled: _autoSyncEnabled,
          syncQueue: _currentSyncQueue,
          progress: _currentProgress,
          error: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<void> _onStartAutoSync(SyncStartAutoSync event, Emitter<SyncState> emit) async {
    try {
      await syncManager.startAutoSync();
      _autoSyncEnabled = true;

      emit(_getCurrentIdleState().copyWith(autoSyncEnabled: true));
    } catch (e, stackTrace) {
      emit(_getCurrentErrorState(e.toString(), stackTrace));
    }
  }

  Future<void> _onStopAutoSync(SyncStopAutoSync event, Emitter<SyncState> emit) async {
    try {
      await syncManager.stopAutoSync();
      _autoSyncEnabled = false;

      emit(_getCurrentIdleState().copyWith(autoSyncEnabled: false));
    } catch (e, stackTrace) {
      emit(_getCurrentErrorState(e.toString(), stackTrace));
    }
  }

  Future<void> _onTriggerSync(SyncTriggerSync event, Emitter<SyncState> emit) async {
    if (!_isConnected) {
      emit(
        SyncPaused(
          isConnected: _isConnected,
          autoSyncEnabled: _autoSyncEnabled,
          syncQueue: _currentSyncQueue,
          progress: _currentProgress,
          reason: 'No internet connection',
        ),
      );
      return;
    }

    try {
      await syncManager.syncNow();
    } catch (e, stackTrace) {
      emit(_getCurrentErrorState(e.toString(), stackTrace));
    }
  }

  Future<void> _onQueueItem(SyncQueueItem event, Emitter<SyncState> emit) async {
    try {
      await syncManager.queueForSync(event.item);

      emit(
        SyncSuccess(
          isConnected: _isConnected,
          autoSyncEnabled: _autoSyncEnabled,
          syncQueue: _currentSyncQueue,
          progress: _currentProgress,
          message: 'Item queued for sync',
        ),
      );
    } catch (e, stackTrace) {
      emit(_getCurrentErrorState(e.toString(), stackTrace));
    }
  }

  Future<void> _onQueueMultipleItems(SyncQueueMultipleItems event, Emitter<SyncState> emit) async {
    try {
      await syncManager.queueMultipleForSync(event.items);

      emit(
        SyncSuccess(
          isConnected: _isConnected,
          autoSyncEnabled: _autoSyncEnabled,
          syncQueue: _currentSyncQueue,
          progress: _currentProgress,
          message: '${event.items.length} items queued for sync',
        ),
      );
    } catch (e, stackTrace) {
      emit(_getCurrentErrorState(e.toString(), stackTrace));
    }
  }

  Future<void> _onRetryFailed(SyncRetryFailed event, Emitter<SyncState> emit) async {
    try {
      await syncManager.retryFailed();

      emit(
        SyncSuccess(
          isConnected: _isConnected,
          autoSyncEnabled: _autoSyncEnabled,
          syncQueue: _currentSyncQueue,
          progress: _currentProgress,
          message: 'Retrying failed sync items',
        ),
      );
    } catch (e, stackTrace) {
      emit(_getCurrentErrorState(e.toString(), stackTrace));
    }
  }

  Future<void> _onRetryItem(SyncRetryItem event, Emitter<SyncState> emit) async {
    try {
      final result = await syncManager.retrySyncItem(event.syncItemId);

      if (result.success) {
        emit(
          SyncSuccess(
            isConnected: _isConnected,
            autoSyncEnabled: _autoSyncEnabled,
            syncQueue: _currentSyncQueue,
            progress: _currentProgress,
            message: 'Item sync retry successful',
          ),
        );
      } else {
        emit(_getCurrentErrorState('Retry failed: ${result.error}', null));
      }
    } catch (e, stackTrace) {
      emit(_getCurrentErrorState(e.toString(), stackTrace));
    }
  }

  Future<void> _onCancelItem(SyncCancelItem event, Emitter<SyncState> emit) async {
    try {
      await syncManager.cancelSyncItem(event.syncItemId);

      emit(
        SyncSuccess(
          isConnected: _isConnected,
          autoSyncEnabled: _autoSyncEnabled,
          syncQueue: _currentSyncQueue,
          progress: _currentProgress,
          message: 'Sync item cancelled',
        ),
      );
    } catch (e, stackTrace) {
      emit(_getCurrentErrorState(e.toString(), stackTrace));
    }
  }

  Future<void> _onClearCompleted(SyncClearCompleted event, Emitter<SyncState> emit) async {
    try {
      await syncManager.clearCompleted();

      emit(
        SyncSuccess(
          isConnected: _isConnected,
          autoSyncEnabled: _autoSyncEnabled,
          syncQueue: _currentSyncQueue,
          progress: _currentProgress,
          message: 'Completed sync items cleared',
        ),
      );
    } catch (e, stackTrace) {
      emit(_getCurrentErrorState(e.toString(), stackTrace));
    }
  }

  void _onConnectivityChanged(SyncConnectivityChanged event, Emitter<SyncState> emit) {
    _isConnected = event.isConnected;

    if (state is SyncPaused && _isConnected) {
      // Resume from paused state when connectivity is restored
      emit(_getCurrentIdleState());
    } else if (!_isConnected && state is SyncInProgress) {
      // Pause if we lose connectivity during sync
      emit(
        SyncPaused(
          isConnected: _isConnected,
          autoSyncEnabled: _autoSyncEnabled,
          syncQueue: _currentSyncQueue,
          progress: _currentProgress,
          reason: 'Lost internet connection',
        ),
      );
    } else {
      // Update connectivity status in current state
      emit(_updateStateWithConnectivity(_isConnected));
    }
  }

  void _onQueueUpdated(SyncQueueUpdated event, Emitter<SyncState> emit) {
    _currentSyncQueue = event.syncItems;
    emit(_updateStateWithSyncQueue(event.syncItems));
  }

  void _onStatusChanged(SyncStatusChanged event, Emitter<SyncState> emit) {
    switch (event.status) {
      case SyncStatus.idle:
        emit(_getCurrentIdleState());
        break;
      case SyncStatus.syncing:
        emit(
          SyncInProgress(
            isConnected: _isConnected,
            autoSyncEnabled: _autoSyncEnabled,
            syncQueue: _currentSyncQueue,
            progress: _currentProgress,
          ),
        );
        break;
      case SyncStatus.paused:
        emit(
          SyncPaused(
            isConnected: _isConnected,
            autoSyncEnabled: _autoSyncEnabled,
            syncQueue: _currentSyncQueue,
            progress: _currentProgress,
            reason: 'Sync paused',
          ),
        );
        break;
      case SyncStatus.error:
        emit(_getCurrentErrorState('Sync error occurred', null));
        break;
    }
  }

  void _onProgressUpdated(SyncProgressUpdated event, Emitter<SyncState> emit) {
    _currentProgress = event.progress;
    emit(_updateStateWithProgress(event.progress));
  }

  // Helper methods

  SyncIdle _getCurrentIdleState() {
    return SyncIdle(
      isConnected: _isConnected,
      autoSyncEnabled: _autoSyncEnabled,
      syncQueue: _currentSyncQueue,
      progress: _currentProgress,
    );
  }

  SyncError _getCurrentErrorState(String error, StackTrace? stackTrace) {
    return SyncError(
      isConnected: _isConnected,
      autoSyncEnabled: _autoSyncEnabled,
      syncQueue: _currentSyncQueue,
      progress: _currentProgress,
      error: error,
      stackTrace: stackTrace,
    );
  }

  SyncState _updateStateWithConnectivity(bool isConnected) {
    if (state is SyncIdle) {
      return (state as SyncIdle).copyWith(isConnected: isConnected);
    } else if (state is SyncInProgress) {
      return (state as SyncInProgress).copyWith(isConnected: isConnected);
    } else if (state is SyncPaused) {
      return (state as SyncPaused).copyWith(isConnected: isConnected);
    } else if (state is SyncError) {
      return (state as SyncError).copyWith(isConnected: isConnected);
    } else if (state is SyncSuccess) {
      return (state as SyncSuccess).copyWith(isConnected: isConnected);
    }
    return state;
  }

  SyncState _updateStateWithSyncQueue(List<SyncItem> syncQueue) {
    if (state is SyncIdle) {
      return (state as SyncIdle).copyWith(syncQueue: syncQueue);
    } else if (state is SyncInProgress) {
      return (state as SyncInProgress).copyWith(syncQueue: syncQueue);
    } else if (state is SyncPaused) {
      return (state as SyncPaused).copyWith(syncQueue: syncQueue);
    } else if (state is SyncError) {
      return (state as SyncError).copyWith(syncQueue: syncQueue);
    } else if (state is SyncSuccess) {
      return (state as SyncSuccess).copyWith(syncQueue: syncQueue);
    }
    return state;
  }

  SyncState _updateStateWithProgress(SyncProgress progress) {
    if (state is SyncIdle) {
      return (state as SyncIdle).copyWith(progress: progress);
    } else if (state is SyncInProgress) {
      return (state as SyncInProgress).copyWith(progress: progress);
    } else if (state is SyncPaused) {
      return (state as SyncPaused).copyWith(progress: progress);
    } else if (state is SyncError) {
      return (state as SyncError).copyWith(progress: progress);
    } else if (state is SyncSuccess) {
      return (state as SyncSuccess).copyWith(progress: progress);
    }
    return state;
  }

  @override
  Future<void> close() async {
    await _connectivitySubscription?.cancel();
    await _syncQueueSubscription?.cancel();
    await _syncStatusSubscription?.cancel();
    await _syncProgressSubscription?.cancel();
    await syncManager.dispose();
    await connectivityService.dispose();
    return super.close();
  }
}
