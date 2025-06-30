import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upload_status.g.dart';

/// Represents the current status of an upload operation
@JsonSerializable()
class UploadStatus extends Equatable {
  const UploadStatus({
    required this.state,
    this.progress = 0.0,
    this.error,
    this.uploadedAt,
    this.retryCount = 0,
    this.nextRetryAt,
  });

  /// The current state of the upload
  final UploadState state;

  /// Upload progress (0.0 to 1.0)
  final double progress;

  /// Error message if upload failed
  final String? error;

  /// Timestamp when upload was completed
  final DateTime? uploadedAt;

  /// Number of retry attempts made
  final int retryCount;

  /// When the next retry should occur
  final DateTime? nextRetryAt;

  // Convenience getters
  bool get isPending => state == UploadState.pending;
  bool get isUploading => state == UploadState.uploading;
  bool get isCompleted => state == UploadState.completed;
  bool get isFailed => state == UploadState.failed;
  bool get isCancelled => state == UploadState.cancelled;
  bool get canRetry => isFailed && retryCount < 3;

  UploadStatus copyWith({
    UploadState? state,
    double? progress,
    String? error,
    DateTime? uploadedAt,
    int? retryCount,
    DateTime? nextRetryAt,
  }) {
    return UploadStatus(
      state: state ?? this.state,
      progress: progress ?? this.progress,
      error: error ?? this.error,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
    );
  }

  factory UploadStatus.fromJson(Map<String, dynamic> json) => _$UploadStatusFromJson(json);

  Map<String, dynamic> toJson() => _$UploadStatusToJson(this);

  @override
  List<Object?> get props => [
        state,
        progress,
        error,
        uploadedAt,
        retryCount,
        nextRetryAt,
      ];
}

/// States that an upload can be in
enum UploadState {
  /// Waiting to be uploaded
  pending,

  /// Currently being uploaded
  uploading,

  /// Successfully uploaded
  completed,

  /// Upload failed
  failed,

  /// Upload was cancelled
  cancelled,
}
