import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:voo_offline_first/voo_offline_first.dart';
import '../helpers/test_helpers.dart';
import '../mocks/mock_implementations.dart';

void main() {
  group('Performance Tests', () {
    group('Sync Manager Performance', () {
      late MockSyncManagerImpl syncManager;

      setUp(() async {
        syncManager = MockSyncManagerImpl();
        await syncManager.initialize();
      });

      tearDown(() async {
        await syncManager.dispose();
      });

      test('should handle large sync queues efficiently', () async {
        const itemCount = 1000;
        final items = TestHelpers.createTestSyncItems(count: itemCount);

        final stats = await TestHelpers.measurePerformance(
          () async => await syncManager.queueMultipleForSync(items),
          iterations: 5,
        );

        print('Queue $itemCount items: $stats');

        // Should complete within reasonable time
        expect(stats.averageMs, lessThan(5000));
        expect(stats.maxMs, lessThan(10000));

        // Verify all items were queued
        final queue = await syncManager.getSyncQueue();
        expect(queue, hasLength(itemCount));
      });

      test('should sync large number of items efficiently', () async {
        const itemCount = 500;
        final items = TestHelpers.createTestSyncItems(count: itemCount);
        await syncManager.queueMultipleForSync(items);

        final stats = await TestHelpers.measurePerformance(
          () async => await syncManager.syncNow(),
          iterations: 3,
        );

        print('Sync $itemCount items: $stats');

        // Should complete within reasonable time
        expect(stats.averageMs, lessThan(10000));
        expect(syncManager.syncedItems, hasLength(itemCount));
      });

      test('should handle rapid queue operations', () async {
        const operationCount = 100;

        final stats = await TestHelpers.measurePerformance(
          () async {
            for (int i = 0; i < operationCount; i++) {
              final item = TestHelpers.createTestSyncItem(id: 'rapid_$i');
              await syncManager.queueForSync(item);
            }
          },
          iterations: 3,
        );

        print('$operationCount rapid queue operations: $stats');

        expect(stats.averageMs, lessThan(3000));

        final queue = await syncManager.getSyncQueue();
        expect(queue, hasLength(operationCount));
      });

      test('should handle concurrent sync operations efficiently', () async {
        const itemsPerBatch = 50;
        const batchCount = 5;

        // Create items
        for (int batch = 0; batch < batchCount; batch++) {
          final items = TestHelpers.createTestSyncItems(
            count: itemsPerBatch,
          ).map((item) => item.copyWith(id: '${item.id}_batch_$batch')).toList();
          await syncManager.queueMultipleForSync(items);
        }

        final stats = await TestHelpers.measurePerformance(
          () async {
            // Start multiple concurrent sync operations
            final futures = List.generate(
              batchCount,
              (_) => syncManager.syncNow(),
            );
            await Future.wait(futures);
          },
          iterations: 2,
        );

        print('Concurrent sync operations: $stats');

        expect(stats.averageMs, lessThan(15000));
        expect(syncManager.syncedItems, hasLength(itemsPerBatch * batchCount));
      });
    });

    group('Repository Performance', () {
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
      });

      test('should save large number of entities efficiently', () async {
        const entityCount = 1000;
        final entities = List.generate(
          entityCount,
          (index) => TestEntity(
            id: 'perf_entity_$index',
            name: 'Performance Entity $index',
            description: 'Description for entity $index',
          ),
        );

        final stats = await TestHelpers.measurePerformance(
          () async => await repository.saveAll(entities),
          iterations: 3,
        );

        print('Save $entityCount entities: $stats');

        expect(stats.averageMs, lessThan(10000));
        expect(await repository.count(), entityCount);
      });

      test('should retrieve entities efficiently', () async {
        const entityCount = 500;

        // Pre-populate repository
        final entities = List.generate(
          entityCount,
          (index) => TestEntity(
            id: 'retrieve_entity_$index',
            name: 'Retrieve Entity $index',
            description: 'Description for entity $index',
          ),
        );
        await repository.saveAll(entities);

        final stats = await TestHelpers.measurePerformance(
          () async => await repository.getAll(),
          iterations: 10,
        );

        print('Retrieve $entityCount entities: $stats');

        expect(stats.averageMs, lessThan(1000));
      });

      test('should handle concurrent read/write operations', () async {
        const operationCount = 100;

        final stats = await TestHelpers.measurePerformance(
          () async {
            final futures = <Future>[];

            // Mix of read and write operations
            for (int i = 0; i < operationCount; i++) {
              if (i % 3 == 0) {
                // Write operation
                final entity = TestEntity(
                  id: 'concurrent_$i',
                  name: 'Concurrent Entity $i',
                  description: 'Description $i',
                );
                futures.add(repository.save(entity));
              } else if (i % 3 == 1) {
                // Read all operation
                futures.add(repository.getAll());
              } else {
                // Count operation
                futures.add(repository.count());
              }
            }

            await Future.wait(futures);
          },
          iterations: 3,
        );

        print('$operationCount concurrent operations: $stats');

        expect(stats.averageMs, lessThan(5000));
      });

      test('should handle rapid status updates efficiently', () async {
        const entityCount = 200;

        // Create entities
        final entities = List.generate(
          entityCount,
          (index) => TestEntity(
            id: 'status_entity_$index',
            name: 'Status Entity $index',
            description: 'Description $index',
          ),
        );
        await repository.saveAll(entities);

        final stats = await TestHelpers.measurePerformance(
          () async {
            for (int i = 0; i < entityCount; i++) {
              await repository.updateUploadStatus(
                'status_entity_$i',
                TestHelpers.createTestUploadStatus(
                  state: UploadState.uploading,
                  progress: i / entityCount,
                ),
              );
            }
          },
          iterations: 3,
        );

        print('$entityCount status updates: $stats');

        expect(stats.averageMs, lessThan(3000));
      });
    });

    group('Memory Usage Tests', () {
      test('should not leak memory with many sync items', () async {
        final syncManager = MockSyncManagerImpl();
        await syncManager.initialize();

        // Create and process multiple batches
        for (int batch = 0; batch < 10; batch++) {
          final items = TestHelpers.createTestSyncItems(count: 100);
          await syncManager.queueMultipleForSync(items);
          await syncManager.syncNow();
          await syncManager.clearCompleted();

          // Allow garbage collection
          await Future.delayed(const Duration(milliseconds: 10));
        }

        // Final queue should be small
        final finalQueue = await syncManager.getSyncQueue();
        expect(finalQueue, hasLength(lessThan(50)));

        await syncManager.dispose();
      });

      test('should handle stream subscriptions without memory leaks', () async {
        final repository = MockOfflineRepository<TestEntity>(
          getId: (entity) => entity.id,
          setId: (entity, id) => entity.copyWith(id: id),
          toJson: (entity) => entity.toJson(),
          fromJson: (json) => TestEntity.fromJson(json),
        );

        final subscriptions = <StreamSubscription>[];

        // Create many subscriptions
        for (int i = 0; i < 100; i++) {
          subscriptions.add(
            repository.watchAll().listen((_) {}),
          );
        }

        // Perform operations
        for (int i = 0; i < 50; i++) {
          await repository.save(TestEntity(
            id: 'memory_test_$i',
            name: 'Memory Test $i',
            description: 'Description $i',
          ));
        }

        // Cancel subscriptions
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }

        await repository.dispose();

        // Test should complete without memory issues
        expect(subscriptions, hasLength(100));
      });
    });

    group('Stress Tests', () {
      test('should handle continuous sync operations', () async {
        final syncManager = MockSyncManagerImpl();
        await syncManager.initialize();
        await syncManager.startAutoSync();

        const duration = Duration(seconds: 10);
        const itemsPerSecond = 10;

        final stopwatch = Stopwatch()..start();
        int itemsQueued = 0;

        while (stopwatch.elapsed < duration) {
          final item = TestHelpers.createTestSyncItem(
            id: 'stress_${itemsQueued++}',
          );
          await syncManager.queueForSync(item);

          if (itemsQueued % itemsPerSecond == 0) {
            await Future.delayed(const Duration(seconds: 1));
          }
        }

        stopwatch.stop();

        print('Stress test: Queued $itemsQueued items in ${stopwatch.elapsed}');

        // Allow final sync to complete
        await Future.delayed(const Duration(seconds: 2));

        expect(itemsQueued, greaterThan(50));
        expect(syncManager.syncedItems.length, greaterThan(30));

        await syncManager.dispose();
      });

      test('should handle rapid connectivity changes', () async {
        final connectivityService = MockConnectivityServiceImpl();
        await connectivityService.initialize();

        const changeCount = 1000;
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < changeCount; i++) {
          connectivityService.setConnected(i % 2 == 0);

          // Small delay to simulate realistic timing
          if (i % 100 == 0) {
            await Future.delayed(const Duration(milliseconds: 1));
          }
        }

        stopwatch.stop();

        print('Connectivity stress test: $changeCount changes in ${stopwatch.elapsed}');

        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
        expect(await connectivityService.isConnected(), false);

        await connectivityService.dispose();
      });
    });

    group('Benchmarks', () {
      test('sync item creation benchmark', () async {
        const itemCount = 10000;

        final stats = await TestHelpers.measurePerformance(
          () async {
            for (int i = 0; i < itemCount; i++) {
              TestHelpers.createTestSyncItem(id: 'benchmark_$i');
            }
          },
          iterations: 5,
        );

        print('Create $itemCount SyncItems: $stats');

        final itemsPerSecond = itemCount / (stats.averageMs / 1000);
        print('Creation rate: ${itemsPerSecond.round()} items/second');

        expect(stats.averageMs, lessThan(1000));
      });

      test('json serialization benchmark', () async {
        const itemCount = 1000;
        final items = TestHelpers.createTestSyncItems(count: itemCount);

        final serializeStats = await TestHelpers.measurePerformance(
          () async {
            for (final item in items) {
              item.toJson();
            }
          },
          iterations: 10,
        );

        final deserializeStats = await TestHelpers.measurePerformance(
          () async {
            for (final item in items) {
              final json = item.toJson();
              SyncItem.fromJson(json);
            }
          },
          iterations: 10,
        );

        print('Serialize $itemCount items: $serializeStats');
        print('Deserialize $itemCount items: $deserializeStats');

        expect(serializeStats.averageMs, lessThan(500));
        expect(deserializeStats.averageMs, lessThan(1000));
      });

      test('priority sorting benchmark', () async {
        const itemCount = 5000;
        final items = TestHelpers.createTestSyncItems(
          count: itemCount,
          priorities: SyncPriority.values,
        );

        final stats = await TestHelpers.measurePerformance(
          () async {
            final sortedItems = SyncUtils.topologicalSort(items);
            expect(sortedItems, hasLength(itemCount));
          },
          iterations: 10,
        );

        print('Sort $itemCount items by priority: $stats');

        expect(stats.averageMs, lessThan(1000));
      });
    });

    group('Resource Usage Tests', () {
      test('should efficiently handle large data payloads', () async {
        final repository = MockOfflineRepository<TestEntity>(
          getId: (entity) => entity.id,
          setId: (entity, id) => entity.copyWith(id: id),
          toJson: (entity) => entity.toJson(),
          fromJson: (json) => TestEntity.fromJson(json),
        );

        // Create entities with large descriptions
        const entityCount = 100;
        final largeDescription = 'x' * 10000; // 10KB description

        final entities = List.generate(
          entityCount,
          (index) => TestEntity(
            id: 'large_entity_$index',
            name: 'Large Entity $index',
            description: largeDescription,
          ),
        );

        final stats = await TestHelpers.measurePerformance(
          () async => await repository.saveAll(entities),
          iterations: 3,
        );

        print('Save $entityCount large entities (~${largeDescription.length * entityCount / 1024}KB total): $stats');

        expect(stats.averageMs, lessThan(15000));
        expect(await repository.count(), entityCount);

        await repository.dispose();
      });

      test('should handle complex nested data efficiently', () async {
        const itemCount = 500;
        final complexItems = List.generate(
          itemCount,
          (index) => TestHelpers.createTestSyncItem(
            id: 'complex_$index',
            data: TestHelpers.generateRealisticTestData(complexity: 3),
          ),
        );

        final syncManager = MockSyncManagerImpl();
        await syncManager.initialize();

        final stats = await TestHelpers.measurePerformance(
          () async {
            await syncManager.queueMultipleForSync(complexItems);
            await syncManager.syncNow();
          },
          iterations: 3,
        );

        print('Process $itemCount complex items: $stats');

        expect(stats.averageMs, lessThan(20000));
        expect(syncManager.syncedItems, hasLength(itemCount));

        await syncManager.dispose();
      });
    });
  });
}
