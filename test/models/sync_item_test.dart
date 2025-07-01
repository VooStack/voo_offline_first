import 'package:flutter_test/flutter_test.dart';
import 'package:voo_offline_first/voo_offline_first.dart';

void main() {
  group('SyncItem', () {
    late SyncItem syncItem;
    late Map<String, dynamic> testData;
    late UploadStatus uploadStatus;

    setUp(() {
      testData = {
        'id': 'test-id',
        'title': 'Test Item',
        'description': 'Test description',
      };

      uploadStatus = const UploadStatus(
        state: UploadState.pending,
        progress: 0.0,
      );

      syncItem = SyncItem(
        id: 'sync-item-1',
        entityType: 'TestEntity',
        entityId: 'entity-1',
        data: testData,
        createdAt: DateTime(2024, 1, 1),
        status: uploadStatus,
        priority: SyncPriority.normal,
        endpoint: '/api/test',
        dependencies: const ['dep-1', 'dep-2'],
      );
    });

    test('should create SyncItem with all properties', () {
      expect(syncItem.id, 'sync-item-1');
      expect(syncItem.entityType, 'TestEntity');
      expect(syncItem.entityId, 'entity-1');
      expect(syncItem.data, testData);
      expect(syncItem.status, uploadStatus);
      expect(syncItem.priority, SyncPriority.normal);
      expect(syncItem.endpoint, '/api/test');
      expect(syncItem.dependencies, ['dep-1', 'dep-2']);
    });

    test('should serialize to JSON correctly', () {
      final json = syncItem.toJson();

      expect(json['id'], 'sync-item-1');
      expect(json['entityType'], 'TestEntity');
      expect(json['entityId'], 'entity-1');
      expect(json['data'], testData);
      expect(json['priority'], 'normal');
      expect(json['endpoint'], '/api/test');
      expect(json['dependencies'], ['dep-1', 'dep-2']);
    });

    test('should deserialize from JSON correctly', () {
      final json = syncItem.toJson();
      final deserializedItem = SyncItem.fromJson(json);

      expect(deserializedItem.id, syncItem.id);
      expect(deserializedItem.entityType, syncItem.entityType);
      expect(deserializedItem.entityId, syncItem.entityId);
      expect(deserializedItem.data, syncItem.data);
      expect(deserializedItem.priority, syncItem.priority);
      expect(deserializedItem.endpoint, syncItem.endpoint);
      expect(deserializedItem.dependencies, syncItem.dependencies);
    });

    test('should create copy with modified properties', () {
      final modifiedStatus = uploadStatus.copyWith(
        state: UploadState.uploading,
        progress: 0.5,
      );

      final copiedItem = syncItem.copyWith(
        status: modifiedStatus,
        priority: SyncPriority.high,
      );

      expect(copiedItem.id, syncItem.id);
      expect(copiedItem.status.state, UploadState.uploading);
      expect(copiedItem.status.progress, 0.5);
      expect(copiedItem.priority, SyncPriority.high);
    });

    test('should be ready for sync when no dependencies', () {
      final itemWithoutDeps = syncItem.copyWith(dependencies: []);
      expect(itemWithoutDeps.isReadyForSync, true);
    });

    test('should not be ready for sync when has dependencies', () {
      expect(syncItem.isReadyForSync, false);
    });

    test('should be retryable when last attempt was long ago', () {
      final itemWithOldAttempt = syncItem.copyWith(
        lastAttemptAt: DateTime.now().subtract(const Duration(minutes: 10)),
        status: uploadStatus.copyWith(
          state: UploadState.failed,
          retryCount: 1,
        ),
      );

      expect(itemWithOldAttempt.shouldRetry, true);
    });

    test('should not be retryable when last attempt was recent', () {
      final itemWithRecentAttempt = syncItem.copyWith(
        lastAttemptAt: DateTime.now().subtract(const Duration(minutes: 2)),
        status: uploadStatus.copyWith(
          state: UploadState.failed,
          retryCount: 1,
        ),
      );

      expect(itemWithRecentAttempt.shouldRetry, false);
    });

    test('should support equality comparison', () {
      final identicalItem = SyncItem(
        id: syncItem.id,
        entityType: syncItem.entityType,
        entityId: syncItem.entityId,
        data: syncItem.data,
        createdAt: syncItem.createdAt,
        status: syncItem.status,
        priority: syncItem.priority,
        endpoint: syncItem.endpoint,
        dependencies: syncItem.dependencies,
      );

      expect(syncItem, equals(identicalItem));
    });
  });
}
