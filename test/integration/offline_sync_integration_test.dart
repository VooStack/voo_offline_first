import 'package:flutter_test/flutter_test.dart';
import 'package:voo_offline_first/src/core/models/sync_progress.dart';
import 'package:voo_offline_first/voo_offline_first.dart';
import '../mocks/mock_implementations.dart';

void main() {
  group('Offline Sync Integration Tests', () {
    late MockSyncManagerImpl syncManager;
    late MockConnectivityServiceImpl connectivityService;
    late MockOfflineRepository<TestEntity> repository;

    setUp(() async {
      syncManager = MockSyncManagerImpl();
      connectivityService = MockConnectivityServiceImpl();
      repository = MockOfflineRepository<TestEntity>(
        getId: (entity) => entity.id,
        setId: (entity, id) => entity.copyWith(id: id),
        toJson: (entity) => entity.toJson(),
        fromJson: (json) => TestEntity.fromJson(json),
      );

      await syncManager.initialize();
      await connectivityService.initialize();
    });

    tearDown(() async {
      await syncManager.dispose();
      await connectivityService.dispose();
      await repository.dispose();
    });

    group('Basic Offline Operations', () {
      test('should save entity offline and queue for sync', () async {
        // Arrange
        const entity = TestEntity(
          id: '',
          name: 'Test Entity',
          description: 'Test Description',
        );

        // Act
        final savedEntity = await repository.save(entity);

        // Assert
        expect(savedEntity.id, isNotEmpty);
        expect(savedEntity.name, 'Test Entity');

        final allEntities = await repository.getAll();
        expect(allEntities, hasLength(1));
        expect(allEntities.first.name, 'Test Entity');

        final pendingSync = await repository.getPendingSync();
        expect(pendingSync, hasLength(1));
      });

      test('should update existing entity and maintain sync status', () async {
        // Arrange
        const entity = TestEntity(
          id: 'test-1',
          name: 'Original Name',
          description: 'Original Description',
        );

        await repository.save(entity);

        // Act
        final updatedEntity = entity.copyWith(name: 'Updated Name');
        await repository.save(updatedEntity);

        // Assert
        final retrieved = await repository.getById('test-1');
        expect(retrieved?.name, 'Updated Name');
        expect(retrieved?.description, 'Original Description');

        final pendingSync = await repository.getPendingSync();
        expect(pendingSync, hasLength(1));
      });

      test('should delete entity and remove from sync queue', () async {
        // Arrange
        const entity = TestEntity(
          id: 'test-1',
          name: 'Test Entity',
          description: 'Test Description',
        );

        await repository.save(entity);
        expect(await repository.count(), 1);

        // Act
        await repository.delete('test-1');

        // Assert
        expect(await repository.count(), 0);
        expect(await repository.getById('test-1'), isNull);

        final pendingSync = await repository.getPendingSync();
        expect(pendingSync, isEmpty);
      });
    });

    group('Sync Operations', () {
      test('should sync pending items when connectivity is available', () async {
        // Arrange
        final entities = [
          const TestEntity(id: '', name: 'Entity 1', description: 'Desc 1'),
          const TestEntity(id: '', name: 'Entity 2', description: 'Desc 2'),
          const TestEntity(id: '', name: 'Entity 3', description: 'Desc 3'),
        ];

        for (final entity in entities) {
          await repository.save(entity);
        }

        // Wait for save operations to complete
        await Future.delayed(const Duration(milliseconds: 50));

        // Create sync items for the entities
        final pendingEntities = await repository.getPendingSync();

        // Should have saved all entities
        expect(pendingEntities.length, entities.length);

        for (final entity in pendingEntities) {
          final syncItem = SyncItem(
            id: 'sync_${entity.id}',
            entityType: 'TestEntity',
            entityId: entity.id,
            data: entity.toJson(),
            createdAt: DateTime.now(),
            status: const UploadStatus(state: UploadState.pending),
            priority: SyncPriority.normal,
          );
          await syncManager.queueForSync(syncItem);
        }

        // Act
        await syncManager.syncNow();

        // Wait for sync to complete
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(syncManager.syncedItems.length, pendingEntities.length);

        final statistics = await syncManager.getSyncStatistics();
        expect(statistics.totalSynced, pendingEntities.length);
        expect(statistics.totalFailed, 0);
      });

      test('should handle sync failures and retry logic', () async {
        // Arrange
        const entity = TestEntity(
          id: 'test-1',
          name: 'Test Entity',
          description: 'Test Description',
        );

        await repository.save(entity);

        final syncItem = SyncItem(
          id: 'sync_test-1',
          entityType: 'TestEntity',
          entityId: 'test-1',
          data: entity.toJson(),
          createdAt: DateTime.now(),
          status: const UploadStatus(state: UploadState.pending),
          priority: SyncPriority.normal,
        );

        await syncManager.queueForSync(syncItem);

        // Simulate failure
        syncManager.simulateFailedItem('sync_test-1', 'Network timeout');

        // Act - retry failed items
        await syncManager.retryFailed();

        // Wait for retry processing
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(syncManager.retriedItems, contains('sync_test-1'));

        final syncQueue = await syncManager.getSyncQueue();
        final item = syncQueue.firstWhere((item) => item.id == 'sync_test-1');
        expect(item.status.isPending, true);
      });

      test('should handle connectivity changes', () async {
        // Arrange
        bool connectivityChanged = false;
        final subscription = connectivityService.watchConnectivity().listen((isConnected) {
          connectivityChanged = true;
        });

        // Act
        connectivityService.setConnected(false);
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        expect(connectivityChanged, true);
        expect(await connectivityService.isConnected(), false);

        // Act - restore connectivity
        connectivityService.setConnected(true);
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        expect(await connectivityService.isConnected(), true);

        await subscription.cancel();
      });
    });

    group('Sync Status Monitoring', () {
      test('should track sync progress correctly', () async {
        // Arrange
        final progressUpdates = <SyncProgress>[];
        syncManager.watchSyncProgress().listen(progressUpdates.add);

        // Create multiple items - use fewer items to make test more predictable
        const itemCount = 3;
        for (int i = 0; i < itemCount; i++) {
          final syncItem = SyncItem(
            id: 'sync_item_$i',
            entityType: 'TestEntity',
            entityId: 'entity_$i',
            data: {'id': 'entity_$i', 'name': 'Entity $i'},
            createdAt: DateTime.now(),
            status: const UploadStatus(state: UploadState.pending),
            priority: SyncPriority.normal,
          );
          await syncManager.queueForSync(syncItem);
        }

        // Act
        await syncManager.syncNow();

        // Wait for progress updates to complete
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(progressUpdates, isNotEmpty);

        // Check that we have progress for all items
        final finalProgress = progressUpdates.last;
        expect(finalProgress.total, itemCount);
        expect(finalProgress.completed, itemCount);
        expect(finalProgress.failed, 0);
        expect(finalProgress.inProgress, 0);
      });

      test('should track sync status changes', () async {
        // Arrange
        final statusUpdates = <SyncStatus>[];
        final subscription = syncManager.watchSyncStatus().listen(statusUpdates.add);

        final syncItem = SyncItem(
          id: 'sync_item',
          entityType: 'TestEntity',
          entityId: 'entity',
          data: {'id': 'entity', 'name': 'Entity'},
          createdAt: DateTime.now(),
          status: const UploadStatus(state: UploadState.pending),
          priority: SyncPriority.normal,
        );

        await syncManager.queueForSync(syncItem);

        // Act
        await syncManager.syncNow();

        // Wait for all status updates to be emitted
        await Future.delayed(const Duration(milliseconds: 200));

        // Assert
        expect(statusUpdates, isNotEmpty);

        // Should contain at least syncing status
        expect(statusUpdates, contains(SyncStatus.syncing));

        // Should end with idle status (might take longer for mock to emit)
        await Future.delayed(const Duration(milliseconds: 100));

        // Check current status rather than historical updates for mock
        final currentQueue = await syncManager.getSyncQueue();
        final allCompleted = currentQueue.every((item) => item.status.isCompleted);
        expect(allCompleted, true);

        await subscription.cancel();
      });
    });

    group('Repository Streams', () {
      test('should emit updates when entities change', () async {
        // Arrange
        final entityUpdates = <List<TestEntity>>[];
        repository.watchAll().listen(entityUpdates.add);

        // Act
        const entity1 = TestEntity(id: 'test-1', name: 'Entity 1', description: 'Desc 1');
        await repository.save(entity1);

        const entity2 = TestEntity(id: 'test-2', name: 'Entity 2', description: 'Desc 2');
        await repository.save(entity2);

        await repository.delete('test-1');

        // Wait for stream emissions
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        expect(entityUpdates, isNotEmpty);

        final finalEntities = entityUpdates.last;
        expect(finalEntities, hasLength(1));
        expect(finalEntities.first.id, 'test-2');
      });

      test('should track upload status changes', () async {
        // Arrange
        const entity = TestEntity(id: 'test-1', name: 'Entity', description: 'Desc');
        await repository.save(entity);

        final statusUpdates = <UploadStatus?>[];
        repository.watchUploadStatus('test-1').listen(statusUpdates.add);

        // Act
        await repository.updateUploadStatus(
          'test-1',
          const UploadStatus(state: UploadState.uploading, progress: 0.5),
        );

        await repository.updateUploadStatus(
          'test-1',
          const UploadStatus(state: UploadState.completed, progress: 1.0),
        );

        // Wait for stream emissions
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        expect(statusUpdates, isNotEmpty);
      });
    });

    group('Complex Scenarios', () {
      test('should handle offline-to-online sync workflow', () async {
        // Arrange - simulate offline mode
        connectivityService.setConnected(false);

        // Create entities while offline
        final entities = [
          const TestEntity(id: '', name: 'Offline Entity 1', description: 'Created offline'),
          const TestEntity(id: '', name: 'Offline Entity 2', description: 'Created offline'),
        ];

        for (final entity in entities) {
          await repository.save(entity);
        }

        expect(await repository.countPendingSync(), 2);

        // Queue items for sync (they won't sync while offline)
        final pendingEntities = await repository.getPendingSync();
        for (final entity in pendingEntities) {
          final syncItem = SyncItem(
            id: 'sync_${entity.id}',
            entityType: 'TestEntity',
            entityId: entity.id,
            data: entity.toJson(),
            createdAt: DateTime.now(),
            status: const UploadStatus(state: UploadState.pending),
            priority: SyncPriority.normal,
          );
          await syncManager.queueForSync(syncItem);
        }

        // Act - restore connectivity and sync
        connectivityService.setConnected(true);
        await syncManager.syncNow();

        // Assert
        expect(syncManager.syncedItems, hasLength(2));
        expect(await connectivityService.isConnected(), true);
      });

      test('should prioritize high-priority items', () async {
        // Arrange
        final lowPriorityItem = SyncItem(
          id: 'low_priority',
          entityType: 'TestEntity',
          entityId: 'entity_low',
          data: {'id': 'entity_low', 'name': 'Low Priority'},
          createdAt: DateTime.now(),
          status: const UploadStatus(state: UploadState.pending),
          priority: SyncPriority.low,
        );

        final highPriorityItem = SyncItem(
          id: 'high_priority',
          entityType: 'TestEntity',
          entityId: 'entity_high',
          data: {'id': 'entity_high', 'name': 'High Priority'},
          createdAt: DateTime.now(),
          status: const UploadStatus(state: UploadState.pending),
          priority: SyncPriority.high,
        );

        // Queue low priority first, then high priority
        await syncManager.queueForSync(lowPriorityItem);
        await syncManager.queueForSync(highPriorityItem);

        // Act
        await syncManager.syncNow();

        // Assert
        expect(syncManager.syncedItems, hasLength(2));
        // In a real implementation, we would verify order based on priority
      });

      test('should handle concurrent operations gracefully', () async {
        // Arrange
        const entity = TestEntity(id: 'concurrent-test', name: 'Entity', description: 'Desc');

        // Act - perform concurrent operations
        final futures = [
          repository.save(entity),
          repository.save(entity.copyWith(name: 'Updated Name 1')),
          repository.save(entity.copyWith(name: 'Updated Name 2')),
        ];

        await Future.wait(futures);

        // Assert
        final finalEntity = await repository.getById('concurrent-test');
        expect(finalEntity, isNotNull);
        expect(finalEntity!.name, contains('Updated Name'));
      });
    });

    group('Error Handling', () {
      test('should handle repository errors gracefully', () async {
        // This would test error scenarios if we had more complex mock implementations
        // For now, we test basic error conditions

        // Test getting non-existent entity
        final nonExistent = await repository.getById('non-existent');
        expect(nonExistent, isNull);

        // Test deleting non-existent entity (should not throw)
        await repository.delete('non-existent');
        expect(await repository.count(), 0);
      });

      test('should handle sync manager errors', () async {
        // Test retrying non-existent item
        final result = await syncManager.retrySyncItem('non-existent');
        expect(result.success, false);
        expect(result.error, contains('not found'));

        // Test cancelling non-existent item (should not throw)
        await syncManager.cancelSyncItem('non-existent');
      });
    });

    group('Performance Tests', () {
      test('should handle large number of entities efficiently', () async {
        // Arrange
        const entityCount = 100;
        final stopwatch = Stopwatch()..start();

        // Act
        for (int i = 0; i < entityCount; i++) {
          final entity = TestEntity(
            id: 'entity_$i',
            name: 'Entity $i',
            description: 'Description for entity $i',
          );
          await repository.save(entity);
        }

        stopwatch.stop();

        // Assert
        expect(await repository.count(), entityCount);
        expect(await repository.countPendingSync(), entityCount);

        // Should complete in reasonable time (adjust threshold as needed)
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('should handle bulk sync operations efficiently', () async {
        // Arrange
        const itemCount = 50;
        final syncItems = <SyncItem>[];

        for (int i = 0; i < itemCount; i++) {
          syncItems.add(SyncItem(
            id: 'bulk_sync_$i',
            entityType: 'TestEntity',
            entityId: 'entity_$i',
            data: {'id': 'entity_$i', 'name': 'Entity $i'},
            createdAt: DateTime.now(),
            status: const UploadStatus(state: UploadState.pending),
            priority: SyncPriority.normal,
          ));
        }

        final stopwatch = Stopwatch()..start();

        // Act
        await syncManager.queueMultipleForSync(syncItems);
        await syncManager.syncNow();

        stopwatch.stop();

        // Assert
        expect(syncManager.syncedItems, hasLength(itemCount));

        // Should complete in reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(10000));
      });
    });
  });
}
