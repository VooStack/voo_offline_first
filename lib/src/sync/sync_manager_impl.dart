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
import '../utils/retry_policy.dart';
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
    // This will be implemented after code generation
    throw UnimplementedError('Will be implemented after code generation');
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
      // This will be implemented after code generation
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
    // This will be implemented after code generation
    throw UnimplementedError('Will be implemented after code generation');
  }

  @override
  Future<SyncResult> retrySyncItem(String syncItemId) async {
    // This will be implemented after code generation
    throw UnimplementedError('Will be implemented after code generation');
  }

  @override
  Future<void> cancelSyncItem(String syncItemId) async {
    // This will be implemented after code generation
    throw UnimplementedError('Will be implemented after code generation');
  }

  @override
  Future<void> clearCompleted() async {
    // This will be implemented after code generation
    throw UnimplementedError('Will be implemented after code generation');
  }

  @override
  Future<List<SyncItem>> getSyncQueue() async {
    // This will be implemented after code generation
    return [];
  }

  @override
  Future<List<SyncItem>> getSyncQueueByStatus(List<UploadState> states) async {
    // This will be implemented after code generation
    return [];
  }

  @override
  Future<SyncStatistics> getSyncStatistics() async {
    return const SyncStatistics(
      totalSynced: 0,
      totalFailed: 0,
      averageSyncTime: Duration(seconds: 30),
      lastSyncAt: null,
    );
  }

  @override
  Stream<List<SyncItem>> watchSyncQueue() {
    return Stream.value([]);
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
}
