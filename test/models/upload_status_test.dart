import 'package:flutter_test/flutter_test.dart';
import 'package:voo_offline_first/voo_offline_first.dart';

void main() {
  group('UploadStatus', () {
    test('should create pending status with default values', () {
      const status = UploadStatus(state: UploadState.pending);

      expect(status.state, UploadState.pending);
      expect(status.progress, 0.0);
      expect(status.error, isNull);
      expect(status.uploadedAt, isNull);
      expect(status.retryCount, 0);
      expect(status.nextRetryAt, isNull);
      expect(status.isPending, true);
      expect(status.isUploading, false);
      expect(status.isCompleted, false);
      expect(status.isFailed, false);
      expect(status.isCancelled, false);
    });

    test('should create uploading status with progress', () {
      const status = UploadStatus(
        state: UploadState.uploading,
        progress: 0.65,
      );

      expect(status.state, UploadState.uploading);
      expect(status.progress, 0.65);
      expect(status.isUploading, true);
      expect(status.isPending, false);
    });

    test('should create completed status with timestamp', () {
      final uploadTime = DateTime.now();
      final status = UploadStatus(
        state: UploadState.completed,
        progress: 1.0,
        uploadedAt: uploadTime,
      );

      expect(status.state, UploadState.completed);
      expect(status.progress, 1.0);
      expect(status.uploadedAt, uploadTime);
      expect(status.isCompleted, true);
      expect(status.canRetry, false);
    });

    test('should create failed status with error and retry info', () {
      final nextRetry = DateTime.now().add(const Duration(minutes: 5));
      final status = UploadStatus(
        state: UploadState.failed,
        error: 'Network timeout',
        retryCount: 2,
        nextRetryAt: nextRetry,
      );

      expect(status.state, UploadState.failed);
      expect(status.error, 'Network timeout');
      expect(status.retryCount, 2);
      expect(status.nextRetryAt, nextRetry);
      expect(status.isFailed, true);
      expect(status.canRetry, true);
    });

    test('should not be retryable after max retries', () {
      const status = UploadStatus(
        state: UploadState.failed,
        error: 'Max retries exceeded',
        retryCount: 3,
      );

      expect(status.isFailed, true);
      expect(status.canRetry, false);
    });

    test('should create cancelled status', () {
      const status = UploadStatus(state: UploadState.cancelled);

      expect(status.state, UploadState.cancelled);
      expect(status.isCancelled, true);
      expect(status.canRetry, false);
    });

    test('should serialize to JSON correctly', () {
      final uploadTime = DateTime(2024, 1, 1, 12, 0, 0);
      final nextRetry = DateTime(2024, 1, 1, 12, 5, 0);

      final status = UploadStatus(
        state: UploadState.failed,
        progress: 0.3,
        error: 'Connection failed',
        uploadedAt: uploadTime,
        retryCount: 1,
        nextRetryAt: nextRetry,
      );

      final json = status.toJson();

      expect(json['state'], 'failed');
      expect(json['progress'], 0.3);
      expect(json['error'], 'Connection failed');
      expect(json['uploadedAt'], uploadTime.toIso8601String());
      expect(json['retryCount'], 1);
      expect(json['nextRetryAt'], nextRetry.toIso8601String());
    });

    test('should deserialize from JSON correctly', () {
      final uploadTime = DateTime(2024, 1, 1, 12, 0, 0);
      final nextRetry = DateTime(2024, 1, 1, 12, 5, 0);

      final json = {
        'state': 'uploading',
        'progress': 0.75,
        'error': null,
        'uploadedAt': null,
        'retryCount': 0,
        'nextRetryAt': null,
      };

      final status = UploadStatus.fromJson(json);

      expect(status.state, UploadState.uploading);
      expect(status.progress, 0.75);
      expect(status.error, isNull);
      expect(status.uploadedAt, isNull);
      expect(status.retryCount, 0);
      expect(status.nextRetryAt, isNull);
    });

    test('should create copy with modified properties', () {
      const originalStatus = UploadStatus(
        state: UploadState.pending,
        progress: 0.0,
        retryCount: 0,
      );

      final modifiedStatus = originalStatus.copyWith(
        state: UploadState.uploading,
        progress: 0.5,
      );

      expect(modifiedStatus.state, UploadState.uploading);
      expect(modifiedStatus.progress, 0.5);
      expect(modifiedStatus.retryCount, 0); // unchanged
    });

    test('should handle all upload states correctly', () {
      const states = [
        UploadState.pending,
        UploadState.uploading,
        UploadState.completed,
        UploadState.failed,
        UploadState.cancelled,
      ];

      for (final state in states) {
        final status = UploadStatus(state: state);

        switch (state) {
          case UploadState.pending:
            expect(status.isPending, true);
            break;
          case UploadState.uploading:
            expect(status.isUploading, true);
            break;
          case UploadState.completed:
            expect(status.isCompleted, true);
            break;
          case UploadState.failed:
            expect(status.isFailed, true);
            break;
          case UploadState.cancelled:
            expect(status.isCancelled, true);
            break;
        }
      }
    });

    test('should support equality comparison', () {
      const status1 = UploadStatus(
        state: UploadState.uploading,
        progress: 0.5,
        retryCount: 1,
      );

      const status2 = UploadStatus(
        state: UploadState.uploading,
        progress: 0.5,
        retryCount: 1,
      );

      expect(status1, equals(status2));
    });
  });
}
