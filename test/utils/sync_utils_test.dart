import 'package:flutter_test/flutter_test.dart';
import 'package:voo_offline_first/voo_offline_first.dart';

void main() {
  group('SyncUtils', () {
    group('generateSyncId', () {
      test('should generate correct sync ID format', () {
        final syncId = SyncUtils.generateSyncId('User', 'user-123');
        expect(syncId, 'User_user-123');
      });

      test('should handle entity ID with underscores', () {
        final syncId = SyncUtils.generateSyncId('Order', 'order_item_456');
        expect(syncId, 'Order_order_item_456');
      });
    });

    group('parseSyncId', () {
      test('should parse simple sync ID correctly', () {
        final (entityType, entityId) = SyncUtils.parseSyncId('User_user-123');
        expect(entityType, 'User');
        expect(entityId, 'user-123');
      });

      test('should parse sync ID with underscores in entity ID', () {
        final (entityType, entityId) = SyncUtils.parseSyncId('Order_order_item_456');
        expect(entityType, 'Order');
        expect(entityId, 'order_item_456');
      });

      test('should throw on invalid sync ID format', () {
        expect(
          () => SyncUtils.parseSyncId('invalid'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('getMimeType', () {
      test('should return correct MIME types for common extensions', () {
        expect(SyncUtils.getMimeType('image.jpg'), 'image/jpeg');
        expect(SyncUtils.getMimeType('document.pdf'), 'application/pdf');
        expect(SyncUtils.getMimeType('data.json'), 'application/json');
        expect(SyncUtils.getMimeType('video.mp4'), 'video/mp4');
      });

      test('should handle uppercase extensions', () {
        expect(SyncUtils.getMimeType('IMAGE.JPG'), 'image/jpeg');
        expect(SyncUtils.getMimeType('DOCUMENT.PDF'), 'application/pdf');
      });

      test('should return null for unknown extensions', () {
        expect(SyncUtils.getMimeType('file.unknown'), isNull);
        expect(SyncUtils.getMimeType('noextension'), isNull);
      });
    });

    group('validateSyncItem', () {
      late SyncItem validSyncItem;

      setUp(() {
        validSyncItem = SyncItem(
          id: 'sync-1',
          entityType: 'User',
          entityId: 'user-1',
          data: const {'name': 'John', 'email': 'john@test.com'},
          createdAt: DateTime.now(),
          status: const UploadStatus(state: UploadState.pending),
          priority: SyncPriority.normal,
        );
      });

      test('should validate valid sync item', () {
        expect(SyncUtils.validateSyncItem(validSyncItem), true);
      });

      test('should reject sync item with empty ID', () {
        final invalidItem = validSyncItem.copyWith(id: '');
        expect(SyncUtils.validateSyncItem(invalidItem), false);
      });

      test('should reject sync item with empty entity type', () {
        final invalidItem = validSyncItem.copyWith(entityType: '');
        expect(SyncUtils.validateSyncItem(invalidItem), false);
      });

      test('should reject sync item with empty entity ID', () {
        final invalidItem = validSyncItem.copyWith(entityId: '');
        expect(SyncUtils.validateSyncItem(invalidItem), false);
      });
    });

    group('isReadyForUpload', () {
      late SyncItem syncItem;

      setUp(() {
        syncItem = SyncItem(
          id: 'sync-1',
          entityType: 'User',
          entityId: 'user-1',
          data: const {'name': 'John'},
          createdAt: DateTime.now(),
          status: const UploadStatus(state: UploadState.pending),
          priority: SyncPriority.normal,
          dependencies: const [],
        );
      });

      test('should be ready when valid and pending with no dependencies', () {
        expect(SyncUtils.isReadyForUpload(syncItem), true);
      });

      test('should not be ready when has dependencies', () {
        final itemWithDeps = syncItem.copyWith(dependencies: ['dep-1']);
        expect(SyncUtils.isReadyForUpload(itemWithDeps), false);
      });

      test('should not be ready when not pending', () {
        final uploadingItem = syncItem.copyWith(
          status: const UploadStatus(state: UploadState.uploading),
        );
        expect(SyncUtils.isReadyForUpload(uploadingItem), false);
      });
    });

    group('calculatePriorityScore', () {
      test('should calculate higher score for higher priority', () {
        final lowPriorityItem = _createSyncItem(SyncPriority.low);
        final highPriorityItem = _createSyncItem(SyncPriority.high);

        final lowScore = SyncUtils.calculatePriorityScore(lowPriorityItem);
        final highScore = SyncUtils.calculatePriorityScore(highPriorityItem);

        expect(highScore, greaterThan(lowScore));
      });

      test('should increase score for older items', () {
        final newItem = _createSyncItem(
          SyncPriority.normal,
          createdAt: DateTime.now(),
        );
        final oldItem = _createSyncItem(
          SyncPriority.normal,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        final newScore = SyncUtils.calculatePriorityScore(newItem);
        final oldScore = SyncUtils.calculatePriorityScore(oldItem);

        expect(oldScore, greaterThan(newScore));
      });

      test('should decrease score for failed items', () {
        final successfulItem = _createSyncItem(
          SyncPriority.normal,
          retryCount: 0,
        );
        final failedItem = _createSyncItem(
          SyncPriority.normal,
          retryCount: 2,
        );

        final successScore = SyncUtils.calculatePriorityScore(successfulItem);
        final failedScore = SyncUtils.calculatePriorityScore(failedItem);

        expect(successScore, greaterThan(failedScore));
      });
    });

    group('extractFileReferences', () {
      test('should extract file paths from simple data', () {
        final data = {
          'image': '/path/to/image.jpg',
          'document': '/docs/file.pdf',
          'text': 'just text',
        };

        final files = SyncUtils.extractFileReferences(data);
        expect(files, contains('/path/to/image.jpg'));
        expect(files, contains('/docs/file.pdf'));
        expect(files, hasLength(2));
      });

      test('should extract file paths from nested data', () {
        final data = {
          'user': {
            'avatar': '/images/avatar.png',
            'name': 'John',
          },
          'attachments': [
            '/files/doc1.pdf',
            '/files/doc2.txt',
            'not-a-file',
          ],
        };

        final files = SyncUtils.extractFileReferences(data);
        expect(files, contains('/images/avatar.png'));
        expect(files, contains('/files/doc1.pdf'));
        expect(files, contains('/files/doc2.txt'));
        expect(files, hasLength(3));
      });

      test('should handle empty or null data', () {
        expect(SyncUtils.extractFileReferences({}), isEmpty);
        expect(SyncUtils.extractFileReferences({'text': 'no files'}), isEmpty);
      });
    });

    group('topologicalSort', () {
      test('should sort items with no dependencies correctly', () {
        final items = [
          _createSyncItemWithId('item-3', dependencies: []),
          _createSyncItemWithId('item-1', dependencies: []),
          _createSyncItemWithId('item-2', dependencies: []),
        ];

        final sorted = SyncUtils.topologicalSort(items);
        expect(sorted, hasLength(3));
        expect(sorted.map((item) => item.id), containsAll(['item-1', 'item-2', 'item-3']));
      });

      test('should sort items with dependencies correctly', () {
        final items = [
          _createSyncItemWithId('item-c', dependencies: ['item-a', 'item-b']),
          _createSyncItemWithId('item-b', dependencies: ['item-a']),
          _createSyncItemWithId('item-a', dependencies: []),
        ];

        final sorted = SyncUtils.topologicalSort(items);
        final sortedIds = sorted.map((item) => item.id).toList();

        final aIndex = sortedIds.indexOf('item-a');
        final bIndex = sortedIds.indexOf('item-b');
        final cIndex = sortedIds.indexOf('item-c');

        expect(aIndex, lessThan(bIndex));
        expect(bIndex, lessThan(cIndex));
      });
    });

    group('isRetryableError', () {
      test('should identify retryable network errors', () {
        expect(SyncUtils.isRetryableError(Exception('timeout')), true);
        expect(SyncUtils.isRetryableError(Exception('connection failed')), true);
        expect(SyncUtils.isRetryableError(Exception('network unreachable')), true);
        expect(SyncUtils.isRetryableError(Exception('HTTP 503')), true);
        expect(SyncUtils.isRetryableError(Exception('HTTP 500')), true);
      });

      test('should identify non-retryable errors', () {
        expect(SyncUtils.isRetryableError(Exception('HTTP 400')), false);
        expect(SyncUtils.isRetryableError(Exception('HTTP 401')), false);
        expect(SyncUtils.isRetryableError(Exception('HTTP 403')), false);
        expect(SyncUtils.isRetryableError(Exception('HTTP 404')), false);
        expect(SyncUtils.isRetryableError(Exception('invalid data')), false);
        expect(SyncUtils.isRetryableError(Exception('malformed request')), false);
      });
    });

    group('generateProgressMessage', () {
      test('should generate correct messages for each state', () {
        const pendingStatus = UploadStatus(state: UploadState.pending);
        expect(
          SyncUtils.generateProgressMessage(pendingStatus),
          'Waiting to upload...',
        );

        const uploadingStatus = UploadStatus(
          state: UploadState.uploading,
          progress: 0.65,
        );
        expect(
          SyncUtils.generateProgressMessage(uploadingStatus),
          'Uploading... 65%',
        );

        const completedStatus = UploadStatus(state: UploadState.completed);
        expect(
          SyncUtils.generateProgressMessage(completedStatus),
          'Upload completed successfully',
        );

        const failedStatus = UploadStatus(
          state: UploadState.failed,
          error: 'Network error',
        );
        expect(
          SyncUtils.generateProgressMessage(failedStatus),
          'Upload failed: Network error',
        );

        const cancelledStatus = UploadStatus(state: UploadState.cancelled);
        expect(
          SyncUtils.generateProgressMessage(cancelledStatus),
          'Upload cancelled',
        );
      });
    });

    group('formatSyncStatistics', () {
      test('should format statistics correctly', () {
        expect(
          SyncUtils.formatSyncStatistics(0, 0, 0, 0),
          'No items to sync',
        );

        expect(
          SyncUtils.formatSyncStatistics(10, 7, 2, 1),
          '7/10 completed (70%), 2 failed, 1 pending',
        );

        expect(
          SyncUtils.formatSyncStatistics(100, 100, 0, 0),
          '100/100 completed (100%), 0 failed, 0 pending',
        );
      });
    });
  });
}

// Helper functions for creating test data
SyncItem _createSyncItem(
  SyncPriority priority, {
  DateTime? createdAt,
  int retryCount = 0,
}) {
  return SyncItem(
    id: 'test-item',
    entityType: 'TestEntity',
    entityId: 'entity-1',
    data: const {'test': 'data'},
    createdAt: createdAt ?? DateTime.now(),
    status: UploadStatus(
      state: UploadState.pending,
      retryCount: retryCount,
    ),
    priority: priority,
  );
}

SyncItem _createSyncItemWithId(
  String id, {
  List<String> dependencies = const [],
}) {
  return SyncItem(
    id: id,
    entityType: 'TestEntity',
    entityId: id,
    data: const {'test': 'data'},
    createdAt: DateTime.now(),
    status: const UploadStatus(state: UploadState.pending),
    priority: SyncPriority.normal,
    dependencies: dependencies,
  );
}
