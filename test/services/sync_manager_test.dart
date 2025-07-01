import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:voo_offline_first/voo_offline_first.dart';
import '../mocks/mock_implementations.dart';

void main() {
  group('SyncManager', () {
    late MockSyncManagerImpl syncManager;

    setUp(() async {
      syncManager = MockSyncManagerImpl();
      await syncManager.initialize();
    });

    tearDown(() async {
      await syncManager.dispose();
      syncManager.reset();
    });

    group('Initialization and Lifecycle', () {
      test('should initialize successfully', () async {
        final newSyncManager = MockSyncManagerImpl();
        expect(() => newSyncManager.getSyncQueue(), throwsA(isA<Exception>()));

        await newSyncManager.initialize();
        final queue = await newSyncManager.getSyncQueue();
        expect(queue, isEmpty);

        await newSyncManager.dispose();
      });

      test('should handle multiple initialize calls', () async {
        await syncManager.initialize();
        await syncManager.initialize();
        await syncManager.initialize();

        final queue = await syncManager.getSyncQueue();
        expect(queue, isEmpty);
      });

      test('should dispose resources properly', () async {
        await syncManager.dispose();
        // After disposal, operations should fail
        expect(() => syncManager.getSyncQueue(), throwsA(isA<Exception>()));
      });
    });

    group('Queue Management', () {
      test('should add single item to sync queue', () async {
        final syncItem = _createTestSyncItem('item-1');

        await syncManager.queueForSync(syncItem);

        final queue = await syncManager.getSyncQueue();
        expect(queue, hasLength(1));
        expect(queue.first.id, 'item-1');
      });

      test('should add multiple items to sync queue', () async {
        final items = [
          _createTestSyncItem('item-1'),
          _createTestSyncItem('item-2'),
          _createTestSyncItem('item-3'),
        ];

        await syncManager.queueMultipleForSync(items);

        final queue = await syncManager.getSyncQueue();
        expect(queue, hasLength(3));
        expect(queue.map((item) => item.id), containsAll(['item-1', 'item-2', 'item-3']));
      });

      test('should replace existing item when queued again', () async {
        final originalItem = _createTestSyncItem('item-1');
        final updatedItem = originalItem.copyWith(
          data: {'updated': 'data'},
        );

        await syncManager.queueForSync(originalItem);
        await syncManager.queueForSync(updatedItem);

        final queue = await syncManager.getSyncQueue();
        expect(queue, hasLength(1));
        expect(queue.first.data['updated'], 'data');
      });

      test('should get sync queue by status', () async {
        final pendingItem = _createTestSyncItem('pending');
        final failedItem = _createTestSyncItem(
          'failed',
          status: const UploadStatus(state: UploadState.failed),
        );
        final completedItem = _createTestSyncItem(
          'completed',
          status: const UploadStatus(state: UploadState.completed),
        );

        await syncManager.queueForSync(pendingItem);
        await syncManager.queueForSync(failedItem);
        await syncManager.queueForSync(completedItem);

        final pendingItems = await syncManager.getSyncQueueByStatus([UploadState.pending]);
        final failedItems = await syncManager.getSyncQueueByStatus([UploadState.failed]);
        final completedItems = await syncManager.getSyncQueueByStatus([UploadState.completed]);

        expect(pendingItems, hasLength(1));
        expect(failedItems, hasLength(1));
        expect(completedItems, hasLength(1));
      });

      test('should clear completed items', () async {
        final pendingItem = _createTestSyncItem('pending');
        final completedItem = _createTestSyncItem(
          'completed',
          status: const UploadStatus(state: UploadState.completed),
        );

        await syncManager.queueForSync(pendingItem);
        await syncManager.queueForSync(completedItem);

        expect(await syncManager.getSyncQueue(), hasLength(2));

        await syncManager.clearCompleted();

        final remainingQueue = await syncManager.getSyncQueue();
        expect(remainingQueue, hasLength(1));
        expect(remainingQueue.first.id, 'pending');
      });
    });

    group('Sync Operations', () {
      test('should sync pending items successfully', () async {
        final items = [
          _createTestSyncItem('item-1'),
          _createTestSyncItem('item-2'),
          _createTestSyncItem('item-3'),
        ];

        await syncManager.queueMultipleForSync(items);

        await syncManager.syncNow();

        expect(syncManager.syncedItems, hasLength(3));
        expect(syncManager.syncedItems.map((item) => item.id), containsAll(['item-1', 'item-2', 'item-3']));
      });

      test('should not sync when already syncing', () async {
        final item = _createTestSyncItem('item-1');
        await syncManager.queueForSync(item);

        // Start sync operations simultaneously
        final future1 = syncManager.syncNow();
        final future2 = syncManager.syncNow();

        await Future.wait([future1, future2]);

        // Should only sync once
        expect(syncManager.syncedItems, hasLength(1));
      });

      test('should handle empty queue gracefully', () async {
        await syncManager.syncNow();

        expect(syncManager.syncedItems, isEmpty);
      });

      test('should track sync progress', () async {
        final progressUpdates = <SyncProgress>[];
        syncManager.watchSyncProgress().listen(progressUpdates.add);

        final items = [
          _createTestSyncItem('item-1'),
          _createTestSyncItem('item-2'),
        ];

        await syncManager.queueMultipleForSync(items);
        await syncManager.syncNow();

        expect(progressUpdates, isNotEmpty);
        final finalProgress = progressUpdates.last;
        expect(finalProgress.completed, 2);
        expect(finalProgress.total, 2);
      });

      test('should emit status changes during sync', () async {
        final statusUpdates = <SyncStatus>[];
        syncManager.watchSyncStatus().listen(statusUpdates.add);

        final item = _createTestSyncItem('item-1');
        await syncManager.queueForSync(item);

        await syncManager.syncNow();

        expect(statusUpdates, contains(SyncStatus.syncing));
        expect(statusUpdates, contains(SyncStatus.idle));
      });
    });

    group('Auto Sync', () {
      test('should start and stop auto sync', () async {
        await syncManager.startAutoSync();
        // Auto sync is now enabled (tested via implementation)

        await syncManager.stopAutoSync();
        // Auto sync is now disabled
      });

      test('should sync automatically when items are queued', () async {
        await syncManager.startAutoSync();

        final item = _createTestSyncItem('auto-sync-item');
        await syncManager.queueForSync(item);

        // Auto sync should trigger
        await Future.delayed(const Duration(milliseconds: 50));

        expect(syncManager.syncedItems, contains(item));
      });
    });

    group('Retry Logic', () {
      test('should retry failed items', () async {
        final item = _createTestSyncItem('retry-item');
        await syncManager.queueForSync(item);

        // Simulate failure
        syncManager.simulateFailedItem('retry-item', 'Network error');

        await syncManager.retryFailed();

        expect(syncManager.retriedItems, contains('retry-item'));
      });

      test('should retry specific item', () async {
        final item = _createTestSyncItem('specific-retry');
        await syncManager.queueForSync(item);

        syncManager.simulateFailedItem('specific-retry', 'Timeout');

        final result = await syncManager.retrySyncItem('specific-retry');

        expect(result.success, true);
        expect(syncManager.retriedItems, contains('specific-retry'));
      });

      test('should fail to retry non-existent item', () async {
        final result = await syncManager.retrySyncItem('non-existent');

        expect(result.success, false);
        expect(result.error, contains('not found'));
      });

      test('should not retry item that cannot be retried', () async {
        final item = _createTestSyncItem(
          'max-retries',
          status: const UploadStatus(
            state: UploadState.failed,
            retryCount: 5, // Exceeds max retries
          ),
        );

        await syncManager.queueForSync(item);

        final result = await syncManager.retrySyncItem('max-retries');

        expect(result.success, false);
        expect(result.error, contains('Cannot retry'));
      });
    });

    group('Item Cancellation', () {
      test('should cancel sync item', () async {
        final item = _createTestSyncItem('cancel-me');
        await syncManager.queueForSync(item);

        await syncManager.cancelSyncItem('cancel-me');

        expect(syncManager.cancelledItems, contains('cancel-me'));

        final queue = await syncManager.getSyncQueue();
        final cancelledItem = queue.firstWhere((item) => item.id == 'cancel-me');
        expect(cancelledItem.status.isCancelled, true);
      });

      test('should handle cancelling non-existent item', () async {
        // Should not throw
        await syncManager.cancelSyncItem('non-existent');

        expect(syncManager.cancelledItems, isNot(contains('non-existent')));
      });
    });

    group('Statistics', () {
      test('should provide accurate sync statistics', () async {
        // Add various items
        final pendingItem = _createTestSyncItem('pending');
        final completedItem = _createTestSyncItem(
          'completed',
          status: const UploadStatus(state: UploadState.completed),
        );
        final failedItem = _createTestSyncItem(
          'failed',
          status: const UploadStatus(state: UploadState.failed),
        );

        await syncManager.queueForSync(pendingItem);
        await syncManager.queueForSync(completedItem);
        await syncManager.queueForSync(failedItem);

        final statistics = await syncManager.getSyncStatistics();

        expect(statistics.totalSynced, 1);
        expect(statistics.totalFailed, 1);
        expect(statistics.averageSyncTime, isA<Duration>());
      });

      test('should handle empty queue statistics', () async {
        final statistics = await syncManager.getSyncStatistics();

        expect(statistics.totalSynced, 0);
        expect(statistics.totalFailed, 0);
        expect(statistics.lastSyncAt, isNull);
      });
    });

    group('Stream Watching', () {
      test('should watch sync queue changes', () async {
        final queueUpdates = <List<SyncItem>>[];
        final subscription = syncManager.watchSyncQueue().listen(queueUpdates.add);

        final item1 = _createTestSyncItem('watch-1');
        final item2 = _createTestSyncItem('watch-2');

        await syncManager.queueForSync(item1);
        await syncManager.queueForSync(item2);
        await syncManager.cancelSyncItem('watch-1');

        await Future.delayed(const Duration(milliseconds: 50));

        expect(queueUpdates, isNotEmpty);
        expect(queueUpdates.last, hasLength(2));

        await subscription.cancel();
      });

      test('should watch sync status changes', () async {
        final statusUpdates = <SyncStatus>[];
        final subscription = syncManager.watchSyncStatus().listen(statusUpdates.add);

        final item = _createTestSyncItem('status-watch');
        await syncManager.queueForSync(item);
        await syncManager.syncNow();

        await Future.delayed(const Duration(milliseconds: 50));

        expect(statusUpdates, contains(SyncStatus.syncing));
        expect(statusUpdates, contains(SyncStatus.idle));

        await subscription.cancel();
      });

      test('should watch sync progress changes', () async {
        final progressUpdates = <SyncProgress>[];
        final subscription = syncManager.watchSyncProgress().listen(progressUpdates.add);

        final items = [
          _createTestSyncItem('progress-1'),
          _createTestSyncItem('progress-2'),
          _createTestSyncItem('progress-3'),
        ];

        await syncManager.queueMultipleForSync(items);
        await syncManager.syncNow();

        await Future.delayed(const Duration(milliseconds: 50));

        expect(progressUpdates, isNotEmpty);

        // Should have progress updates showing increasing completion
        final completedCounts = progressUpdates.map((p) => p.completed).toList();
        expect(completedCounts.last, 3);

        await subscription.cancel();
      });
    });

    group('Sync Strategies', () {
      test('should set sync strategy', () async {
        // Should not throw
        syncManager.setSyncStrategy(SyncStrategy.immediate);
        syncManager.setSyncStrategy(SyncStrategy.batched);
        syncManager.setSyncStrategy(SyncStrategy.scheduled);
      });
    });

    group('Custom Sync Handlers', () {
      test('should register sync handler', () async {
        final handler = MockSyncHandler();

        // Should not throw
        syncManager.registerSyncHandler('CustomEntity', handler);
      });
    });

    group('Error Scenarios', () {
      test('should handle sync errors gracefully', () async {
        final item = _createTestSyncItem('error-item');
        await syncManager.queueForSync(item);

        // Simulate error during sync
        syncManager.simulateError();

        // Should not throw
        await syncManager.syncNow();
      });

      test('should handle operation on uninitialized manager', () async {
        final uninitializedManager = MockSyncManagerImpl();

        expect(
          () => uninitializedManager.getSyncQueue(),
          throwsA(isA<Exception>()),
        );

        expect(
          () => uninitializedManager.queueForSync(_createTestSyncItem('test')),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Performance', () {
      test('should handle large sync queues efficiently', () async {
        const itemCount = 100;
        final items = List.generate(
          itemCount,
          (index) => _createTestSyncItem('item-$index'),
        );

        final stopwatch = Stopwatch()..start();

        await syncManager.queueMultipleForSync(items);
        await syncManager.syncNow();

        stopwatch.stop();

        expect(syncManager.syncedItems, hasLength(itemCount));
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('should handle rapid queue operations efficiently', () async {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 50; i++) {
          final item = _createTestSyncItem('rapid-$i');
          await syncManager.queueForSync(item);
        }

        stopwatch.stop();

        final queue = await syncManager.getSyncQueue();
        expect(queue, hasLength(50));
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test('should handle concurrent sync operations', () async {
        final items = List.generate(
          10,
          (index) => _createTestSyncItem('concurrent-$index'),
        );

        await syncManager.queueMultipleForSync(items);

        // Start multiple sync operations concurrently
        final syncFutures = List.generate(
          5,
          (_) => syncManager.syncNow(),
        );

        await Future.wait(syncFutures);

        // Should sync items exactly once
        expect(syncManager.syncedItems, hasLength(10));
      });
    });

    group('Complex Workflows', () {
      test('should handle mixed operations workflow', () async {
        // Queue initial items
        final initialItems = [
          _createTestSyncItem('initial-1'),
          _createTestSyncItem('initial-2'),
        ];
        await syncManager.queueMultipleForSync(initialItems);

        // Start auto sync
        await syncManager.startAutoSync();

        // Add more items
        await syncManager.queueForSync(_createTestSyncItem('additional-1'));

        // Simulate some failures
        syncManager.simulateFailedItem('initial-1', 'Network error');

        // Retry failed
        await syncManager.retryFailed();

        // Cancel one item
        await syncManager.cancelSyncItem('additional-1');

        // Get final statistics
        final statistics = await syncManager.getSyncStatistics();
        final queue = await syncManager.getSyncQueue();

        expect(queue, hasLength(3)); // All items still in queue
        expect(syncManager.retriedItems, contains('initial-1'));
        expect(syncManager.cancelledItems, contains('additional-1'));
      });

      test('should handle priority-based sync ordering', () async {
        final lowPriorityItem = _createTestSyncItem(
          'low',
          priority: SyncPriority.low,
        );
        final normalPriorityItem = _createTestSyncItem(
          'normal',
          priority: SyncPriority.normal,
        );
        final highPriorityItem = _createTestSyncItem(
          'high',
          priority: SyncPriority.high,
        );

        // Queue in reverse priority order
        await syncManager.queueForSync(lowPriorityItem);
        await syncManager.queueForSync(normalPriorityItem);
        await syncManager.queueForSync(highPriorityItem);

        await syncManager.syncNow();

        expect(syncManager.syncedItems, hasLength(3));
        // In a real implementation, we would verify sync order
      });
    });
  });
}

// Helper functions
SyncItem _createTestSyncItem(
  String id, {
  SyncPriority priority = SyncPriority.normal,
  UploadStatus? status,
  Map<String, dynamic>? data,
}) {
  return SyncItem(
    id: id,
    entityType: 'TestEntity',
    entityId: id,
    data: data ?? {'id': id, 'name': 'Test $id'},
    createdAt: DateTime.now(),
    status: status ?? const UploadStatus(state: UploadState.pending),
    priority: priority,
  );
}

class MockSyncHandler implements SyncHandler {
  final List<SyncItem> syncedItems = [];

  @override
  Future<SyncResult> sync(SyncItem item) async {
    syncedItems.add(item);
    return SyncResult.success();
  }
}
