import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/network_info.dart';
import '../utils/constants.dart';
import 'sync_status.dart';

/// Manages synchronization between local and remote data sources
abstract class SyncManager {
  /// Stream of sync status updates
  Stream<SyncState> get syncStateStream;

  /// Current sync state
  SyncState get currentState;

  /// Start synchronization
  Future<void> startSync();

  /// Stop synchronization
  Future<void> stopSync();

  /// Force sync now
  Future<void> syncNow();

  /// Register a sync handler for a specific entity type
  void registerSyncHandler(String entityType, SyncHandler handler);

  /// Unregister a sync handler
  void unregisterSyncHandler(String entityType);

  /// Clear sync errors
  Future<void> clearErrors();

  /// Retry failed syncs
  Future<void> retryFailedSyncs();
}

/// Handler for syncing specific entity types
abstract class SyncHandler {
  /// Get entities that need syncing
  Future<List<dynamic>> getPendingEntities();

  /// Sync entities to remote
  Future<void> syncEntities(List<dynamic> entities);

  /// Handle sync conflicts
  Future<void> resolveConflict(dynamic localEntity, dynamic remoteEntity);
}

/// Default implementation of SyncManager
class SyncManagerImpl implements SyncManager {
  final NetworkInfo _networkInfo;
  final SharedPreferences _prefs;
  final Map<String, SyncHandler> _handlers = {};

  final _syncStateController = BehaviorSubject<SyncState>.seeded(
    const SyncState(),
  );

  Timer? _syncTimer;
  StreamSubscription? _connectivitySubscription;
  bool _isDisposed = false;

  SyncManagerImpl({
    required NetworkInfo networkInfo,
    required SharedPreferences prefs,
  })  : _networkInfo = networkInfo,
        _prefs = prefs {
    _initialize();
  }

  void _initialize() {
    // Listen to connectivity changes
    _connectivitySubscription = _networkInfo.connectivityStream.listen(
      (isConnected) {
        if (isConnected && !currentState.isSyncing) {
          syncNow();
        }
      },
    );

    // Start periodic sync
    _startPeriodicSync();
  }

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      OfflineFirstConstants.defaultSyncInterval,
      (_) => syncNow(),
    );
  }

  @override
  Stream<SyncState> get syncStateStream => _syncStateController.stream;

  @override
  SyncState get currentState => _syncStateController.value;

  @override
  Future<void> startSync() async {
    if (_isDisposed) return;
    _startPeriodicSync();
    await syncNow();
  }

  @override
  Future<void> stopSync() async {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  @override
  Future<void> syncNow() async {
    if (_isDisposed || currentState.isSyncing) return;

    // Check network connectivity
    if (!await _networkInfo.isConnected) return;

    // Update state to syncing
    _updateState(currentState.copyWith(isSyncing: true, progress: 0.0));

    try {
      final errors = <SyncError>[];
      var pendingCount = 0;

      // Calculate total items to sync
      for (final handler in _handlers.values) {
        final pending = await handler.getPendingEntities();
        pendingCount += pending.length;
      }

      if (pendingCount == 0) {
        _updateState(
          currentState.copyWith(
            isSyncing: false,
            lastSyncTime: DateTime.now(),
            pendingChanges: 0,
          ),
        );
        await _saveLastSyncTime();
        return;
      }

      var processed = 0;

      // Sync each entity type
      for (final entry in _handlers.entries) {
        final entityType = entry.key;
        final handler = entry.value;

        try {
          final pendingEntities = await handler.getPendingEntities();

          if (pendingEntities.isNotEmpty) {
            await handler.syncEntities(pendingEntities);
            processed += pendingEntities.length;

            // Update progress
            final progress = processed / pendingCount;
            _updateState(currentState.copyWith(progress: progress));
          }
        } catch (e) {
          errors.add(
            SyncError(
              entityId: '',
              entityType: entityType,
              message: e.toString(),
              timestamp: DateTime.now(),
              type: SyncErrorType.unknown,
            ),
          );
        }
      }

      // Update final state
      _updateState(
        currentState.copyWith(
          isSyncing: false,
          lastSyncTime: DateTime.now(),
          pendingChanges: pendingCount - processed,
          errors: errors,
        ),
      );

      await _saveLastSyncTime();
    } catch (e) {
      _updateState(
        currentState.copyWith(
          isSyncing: false,
          errors: [
            ...currentState.errors,
            SyncError(
              entityId: '',
              entityType: 'general',
              message: e.toString(),
              timestamp: DateTime.now(),
              type: SyncErrorType.unknown,
            ),
          ],
        ),
      );
    }
  }

  @override
  void registerSyncHandler(String entityType, SyncHandler handler) {
    _handlers[entityType] = handler;
  }

  @override
  void unregisterSyncHandler(String entityType) {
    _handlers.remove(entityType);
  }

  @override
  Future<void> clearErrors() async {
    _updateState(currentState.copyWith(errors: []));
  }

  @override
  Future<void> retryFailedSyncs() async {
    await clearErrors();
    await syncNow();
  }

  void _updateState(SyncState state) {
    if (!_isDisposed) {
      _syncStateController.add(state);
    }
  }

  Future<void> _saveLastSyncTime() async {
    await _prefs.setString(
      OfflineFirstConstants.lastSyncKey,
      DateTime.now().toIso8601String(),
    );
  }

  void dispose() {
    _isDisposed = true;
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    _syncStateController.close();
  }
}
