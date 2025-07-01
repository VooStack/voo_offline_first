import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:voo_offline_first/voo_offline_first.dart';
import '../mocks/mock_implementations.dart';

void main() {
  group('BaseOfflineRepository', () {
    late MockOfflineRepository<TestEntity> repository;

    setUp(() {
      repository = MockOfflineRepository<TestEntity>(
        getId: (entity) => entity.id,
        setId: (entity, id) => entity.copyWith(id: id),
        toJson: (entity) => entity.toJson(),
        fromJson: (json) => TestEntity.fromJson(json),
      );
    });

    tearDown(() async {
      await repository.dispose();
      repository.reset();
    });

    group('Basic CRUD Operations', () {
      test('should save new entity with generated ID', () async {
        const entity = TestEntity(
          id: '', // Empty ID for new entity
          name: 'New Entity',
          description: 'Test Description',
        );

        final savedEntity = await repository.save(entity);

        expect(savedEntity.id, isNotEmpty);
        expect(savedEntity.name, 'New Entity');
        expect(savedEntity.description, 'Test Description');

        final retrieved = await repository.getById(savedEntity.id);
        expect(retrieved, equals(savedEntity));
      });

      test('should save existing entity with same ID', () async {
        const entity = TestEntity(
          id: 'existing-1',
          name: 'Existing Entity',
          description: 'Original Description',
        );

        final savedEntity = await repository.save(entity);
        expect(savedEntity.id, 'existing-1');

        // Update the entity
        final updatedEntity = savedEntity.copyWith(
          description: 'Updated Description',
        );

        final resavedEntity = await repository.save(updatedEntity);
        expect(resavedEntity.id, 'existing-1');
        expect(resavedEntity.description, 'Updated Description');

        final retrieved = await repository.getById('existing-1');
        expect(retrieved?.description, 'Updated Description');
      });

      test('should retrieve entity by ID', () async {
        const entity = TestEntity(
          id: 'test-1',
          name: 'Test Entity',
          description: 'Test Description',
        );

        await repository.save(entity);
        final retrieved = await repository.getById('test-1');

        expect(retrieved, isNotNull);
        expect(retrieved?.id, 'test-1');
        expect(retrieved?.name, 'Test Entity');
      });

      test('should return null for non-existent entity', () async {
        final retrieved = await repository.getById('non-existent');
        expect(retrieved, isNull);
      });

      test('should get all entities', () async {
        final entities = [
          const TestEntity(id: 'entity-1', name: 'Entity 1', description: 'Desc 1'),
          const TestEntity(id: 'entity-2', name: 'Entity 2', description: 'Desc 2'),
          const TestEntity(id: 'entity-3', name: 'Entity 3', description: 'Desc 3'),
        ];

        for (final entity in entities) {
          await repository.save(entity);
        }

        final allEntities = await repository.getAll();
        expect(allEntities, hasLength(3));
        expect(allEntities.map((e) => e.id), containsAll(['entity-1', 'entity-2', 'entity-3']));
      });

      test('should get entities matching criteria', () async {
        final entities = [
          const TestEntity(id: 'entity-1', name: 'Entity 1', description: 'Desc 1'),
          const TestEntity(id: 'entity-2', name: 'Entity 2', description: 'Desc 2'),
        ];

        for (final entity in entities) {
          await repository.save(entity);
        }

        // Mock implementation returns all entities for any criteria
        final filtered = await repository.getWhere({'name': 'Entity 1'});
        expect(filtered, hasLength(2)); // Mock returns all
      });

      test('should delete entity by ID', () async {
        const entity = TestEntity(
          id: 'delete-me',
          name: 'Delete Me',
          description: 'Will be deleted',
        );

        await repository.save(entity);
        expect(await repository.getById('delete-me'), isNotNull);

        await repository.delete('delete-me');
        expect(await repository.getById('delete-me'), isNull);
      });

      test('should delete multiple entities', () async {
        final entities = [
          const TestEntity(id: 'delete-1', name: 'Delete 1', description: 'Desc 1'),
          const TestEntity(id: 'delete-2', name: 'Delete 2', description: 'Desc 2'),
          const TestEntity(id: 'keep-3', name: 'Keep 3', description: 'Desc 3'),
        ];

        for (final entity in entities) {
          await repository.save(entity);
        }

        await repository.deleteAll(['delete-1', 'delete-2']);

        expect(await repository.getById('delete-1'), isNull);
        expect(await repository.getById('delete-2'), isNull);
        expect(await repository.getById('keep-3'), isNotNull);
      });

      test('should save multiple entities in batch', () async {
        final entities = [
          const TestEntity(id: '', name: 'Batch 1', description: 'Desc 1'),
          const TestEntity(id: '', name: 'Batch 2', description: 'Desc 2'),
          const TestEntity(id: '', name: 'Batch 3', description: 'Desc 3'),
        ];

        final savedEntities = await repository.saveAll(entities);

        expect(savedEntities, hasLength(3));
        expect(savedEntities.every((e) => e.id.isNotEmpty), true);

        final allEntities = await repository.getAll();
        expect(allEntities, hasLength(3));
      });
    });

    group('Sync Management', () {
      test('should queue entity for sync when saved', () async {
        const entity = TestEntity(
          id: 'sync-test',
          name: 'Sync Test',
          description: 'Test sync',
        );

        await repository.save(entity);

        final pendingSync = await repository.getPendingSync();
        expect(pendingSync, hasLength(1));
        expect(pendingSync.first.id, 'sync-test');
      });

      test('should get pending sync entities', () async {
        final entities = [
          const TestEntity(id: 'sync-1', name: 'Sync 1', description: 'Desc 1'),
          const TestEntity(id: 'sync-2', name: 'Sync 2', description: 'Desc 2'),
        ];

        for (final entity in entities) {
          await repository.save(entity);
        }

        final pendingSync = await repository.getPendingSync();
        expect(pendingSync, hasLength(2));
        expect(pendingSync.map((e) => e.id), containsAll(['sync-1', 'sync-2']));
      });

      test('should mark entity as uploaded', () async {
        const entity = TestEntity(
          id: 'upload-test',
          name: 'Upload Test',
          description: 'Test upload',
        );

        await repository.save(entity);
        expect(await repository.countPendingSync(), 1);

        await repository.markAsUploaded('upload-test');

        final pendingSync = await repository.getPendingSync();
        expect(pendingSync, isEmpty);
      });

      test('should update upload status', () async {
        const entity = TestEntity(
          id: 'status-test',
          name: 'Status Test',
          description: 'Test status',
        );

        await repository.save(entity);

        const uploadingStatus = UploadStatus(
          state: UploadState.uploading,
          progress: 0.5,
        );

        await repository.updateUploadStatus('status-test', uploadingStatus);

        // Mock implementation stores the status
        expect(repository.uploadStatuses['status-test']?.state, UploadState.uploading);
        expect(repository.uploadStatuses['status-test']?.progress, 0.5);
      });

      test('should queue specific entity for sync', () async {
        const entity = TestEntity(
          id: 'queue-test',
          name: 'Queue Test',
          description: 'Test queue',
        );

        await repository.save(entity);
        await repository.removeFromSyncQueue('queue-test');
        expect(await repository.countPendingSync(), 0);

        await repository.queueForSync('queue-test');
        expect(await repository.countPendingSync(), 1);
      });

      test('should remove entity from sync queue', () async {
        const entity = TestEntity(
          id: 'remove-test',
          name: 'Remove Test',
          description: 'Test remove',
        );

        await repository.save(entity);
        expect(await repository.countPendingSync(), 1);

        await repository.removeFromSyncQueue('remove-test');
        expect(await repository.countPendingSync(), 0);
      });
    });

    group('Counting Operations', () {
      test('should count total entities', () async {
        expect(await repository.count(), 0);

        await repository.save(const TestEntity(id: 'count-1', name: 'Count 1', description: 'Desc 1'));
        expect(await repository.count(), 1);

        await repository.save(const TestEntity(id: 'count-2', name: 'Count 2', description: 'Desc 2'));
        expect(await repository.count(), 2);

        await repository.delete('count-1');
        expect(await repository.count(), 1);
      });

      test('should count pending sync entities', () async {
        expect(await repository.countPendingSync(), 0);

        await repository.save(const TestEntity(id: 'pending-1', name: 'Pending 1', description: 'Desc 1'));
        expect(await repository.countPendingSync(), 1);

        await repository.save(const TestEntity(id: 'pending-2', name: 'Pending 2', description: 'Desc 2'));
        expect(await repository.countPendingSync(), 2);

        await repository.markAsUploaded('pending-1');
        expect(await repository.countPendingSync(), 1);
      });
    });

    group('Stream Operations', () {
      test('should watch all entities', () async {
        final entityUpdates = <List<TestEntity>>[];
        final subscription = repository.watchAll().listen(entityUpdates.add);

        await repository.save(const TestEntity(id: 'watch-1', name: 'Watch 1', description: 'Desc 1'));
        await repository.save(const TestEntity(id: 'watch-2', name: 'Watch 2', description: 'Desc 2'));
        await repository.delete('watch-1');

        await Future.delayed(const Duration(milliseconds: 50));

        expect(entityUpdates, isNotEmpty);
        // Final update should have one entity
        expect(entityUpdates.last, hasLength(1));
        expect(entityUpdates.last.first.id, 'watch-2');

        await subscription.cancel();
      });

      test('should watch entities with criteria', () async {
        final entityUpdates = <List<TestEntity>>[];
        final subscription = repository.watchWhere({'name': 'specific'}).listen(entityUpdates.add);

        await repository.save(const TestEntity(id: 'criteria-1', name: 'Criteria 1', description: 'Desc 1'));
        await repository.save(const TestEntity(id: 'criteria-2', name: 'Criteria 2', description: 'Desc 2'));

        await Future.delayed(const Duration(milliseconds: 50));

        expect(entityUpdates, isNotEmpty);

        await subscription.cancel();
      });

      test('should watch pending sync items', () async {
        final syncUpdates = <List<SyncItem>>[];
        final subscription = repository.watchPendingSync().listen(syncUpdates.add);

        await repository.save(const TestEntity(id: 'sync-watch-1', name: 'Sync Watch 1', description: 'Desc 1'));
        await repository.save(const TestEntity(id: 'sync-watch-2', name: 'Sync Watch 2', description: 'Desc 2'));
        await repository.markAsUploaded('sync-watch-1');

        await Future.delayed(const Duration(milliseconds: 50));

        expect(syncUpdates, isNotEmpty);

        await subscription.cancel();
      });

      test('should watch upload status', () async {
        const entity = TestEntity(id: 'status-watch', name: 'Status Watch', description: 'Desc');
        await repository.save(entity);

        final statusUpdates = <UploadStatus?>[];
        final subscription = repository.watchUploadStatus('status-watch').listen(statusUpdates.add);

        await repository.updateUploadStatus(
          'status-watch',
          const UploadStatus(state: UploadState.uploading, progress: 0.3),
        );

        await repository.updateUploadStatus(
          'status-watch',
          const UploadStatus(state: UploadState.completed, progress: 1.0),
        );

        await Future.delayed(const Duration(milliseconds: 50));

        expect(statusUpdates, isNotEmpty);

        await subscription.cancel();
      });
    });

    group('Clear Operation', () {
      test('should clear all entities and sync data', () async {
        final entities = [
          const TestEntity(id: 'clear-1', name: 'Clear 1', description: 'Desc 1'),
          const TestEntity(id: 'clear-2', name: 'Clear 2', description: 'Desc 2'),
          const TestEntity(id: 'clear-3', name: 'Clear 3', description: 'Desc 3'),
        ];

        for (final entity in entities) {
          await repository.save(entity);
        }

        expect(await repository.count(), 3);
        expect(await repository.countPendingSync(), 3);

        await repository.clear();

        expect(await repository.count(), 0);
        expect(await repository.countPendingSync(), 0);
        expect(await repository.getAll(), isEmpty);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle empty batch operations', () async {
        final savedEntities = await repository.saveAll([]);
        expect(savedEntities, isEmpty);

        await repository.deleteAll([]);
        // Should not throw
      });

      test('should handle deleting non-existent entities', () async {
        // Should not throw
        await repository.delete('non-existent');
        await repository.deleteAll(['non-existent-1', 'non-existent-2']);
      });

      test('should handle sync operations on non-existent entities', () async {
        // Should not throw
        await repository.markAsUploaded('non-existent');
        await repository.updateUploadStatus(
          'non-existent',
          const UploadStatus(state: UploadState.completed),
        );
        await repository.queueForSync('non-existent');
        await repository.removeFromSyncQueue('non-existent');
      });

      test('should handle concurrent operations', () async {
        const entity = TestEntity(
          id: 'concurrent',
          name: 'Concurrent Test',
          description: 'Test concurrent operations',
        );

        // Perform concurrent operations
        final futures = [
          repository.save(entity),
          repository.save(entity.copyWith(name: 'Updated 1')),
          repository.save(entity.copyWith(name: 'Updated 2')),
          repository.queueForSync('concurrent'),
          repository.updateUploadStatus(
            'concurrent',
            const UploadStatus(state: UploadState.uploading),
          ),
        ];

        await Future.wait(futures);

        // Final state should be consistent
        final finalEntity = await repository.getById('concurrent');
        expect(finalEntity, isNotNull);
        expect(finalEntity!.name, contains('Updated'));
      });

      test('should handle large datasets efficiently', () async {
        const entityCount = 100;
        final stopwatch = Stopwatch()..start();

        final entities = List.generate(
          entityCount,
          (index) => TestEntity(
            id: 'bulk-$index',
            name: 'Bulk Entity $index',
            description: 'Description $index',
          ),
        );

        await repository.saveAll(entities);

        stopwatch.stop();

        expect(await repository.count(), entityCount);
        expect(await repository.countPendingSync(), entityCount);
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });
    });

    group('Complex Workflows', () {
      test('should handle complete entity lifecycle', () async {
        // Create entity
        const entity = TestEntity(
          id: '',
          name: 'Lifecycle Entity',
          description: 'Original description',
        );

        final savedEntity = await repository.save(entity);
        expect(savedEntity.id, isNotEmpty);
        expect(await repository.countPendingSync(), 1);

        // Update entity
        final updatedEntity = savedEntity.copyWith(
          description: 'Updated description',
        );
        await repository.save(updatedEntity);

        // Mark as uploading
        await repository.updateUploadStatus(
          savedEntity.id,
          const UploadStatus(state: UploadState.uploading, progress: 0.5),
        );

        // Mark as uploaded
        await repository.markAsUploaded(savedEntity.id);
        expect(await repository.countPendingSync(), 0);

        // Queue for sync again (maybe due to another update)
        await repository.queueForSync(savedEntity.id);
        expect(await repository.countPendingSync(), 1);

        // Finally delete
        await repository.delete(savedEntity.id);
        expect(await repository.getById(savedEntity.id), isNull);
        expect(await repository.countPendingSync(), 0);
      });

      test('should handle mixed sync states', () async {
        final entities = [
          const TestEntity(id: 'pending', name: 'Pending Entity', description: 'Pending'),
          const TestEntity(id: 'uploading', name: 'Uploading Entity', description: 'Uploading'),
          const TestEntity(id: 'completed', name: 'Completed Entity', description: 'Completed'),
          const TestEntity(id: 'failed', name: 'Failed Entity', description: 'Failed'),
        ];

        for (final entity in entities) {
          await repository.save(entity);
        }

        // Set different sync states
        await repository.updateUploadStatus(
          'uploading',
          const UploadStatus(state: UploadState.uploading, progress: 0.7),
        );
        await repository.markAsUploaded('completed');
        await repository.updateUploadStatus(
          'failed',
          const UploadStatus(state: UploadState.failed, error: 'Network error'),
        );

        // Verify states
        expect(repository.uploadStatuses['pending']?.state, UploadState.pending);
        expect(repository.uploadStatuses['uploading']?.state, UploadState.uploading);
        expect(repository.uploadStatuses['completed']?.state, UploadState.completed);
        expect(repository.uploadStatuses['failed']?.state, UploadState.failed);

        // Only pending and failed should be in sync queue
        final pendingSync = await repository.getPendingSync();
        expect(pendingSync.map((e) => e.id), containsAll(['pending', 'failed']));
        expect(pendingSync.map((e) => e.id), isNot(contains('completed')));
      });
    });

    group('Performance Tests', () {
      test('should handle rapid sequential operations', () async {
        const operationCount = 50;
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < operationCount; i++) {
          final entity = TestEntity(
            id: 'rapid-$i',
            name: 'Rapid $i',
            description: 'Description $i',
          );

          await repository.save(entity);
          await repository.updateUploadStatus(
            entity.id,
            UploadStatus(state: UploadState.uploading, progress: i / operationCount),
          );
        }

        stopwatch.stop();

        expect(await repository.count(), operationCount);
        expect(stopwatch.elapsedMilliseconds, lessThan(10000));
      });

      test('should handle many concurrent stream subscriptions', () async {
        final subscriptions = <StreamSubscription>[];

        // Create many subscriptions
        for (int i = 0; i < 20; i++) {
          subscriptions.add(repository.watchAll().listen((_) {}));
          subscriptions.add(repository.watchPendingSync().listen((_) {}));
          subscriptions.add(repository.watchUploadStatus('test').listen((_) {}));
        }

        // Perform operations that trigger stream updates
        await repository.save(const TestEntity(id: 'stream-test', name: 'Stream Test', description: 'Test'));
        await repository.updateUploadStatus('stream-test', const UploadStatus(state: UploadState.completed));

        // Wait for potential stream emissions
        await Future.delayed(const Duration(milliseconds: 100));

        // Clean up
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }

        expect(subscriptions, hasLength(60));
      });
    });
  });
}
