// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadStatus _$UploadStatusFromJson(Map<String, dynamic> json) => UploadStatus(
      state: $enumDecode(_$UploadStateEnumMap, json['state']),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      error: json['error'] as String?,
      uploadedAt: json['uploadedAt'] == null
          ? null
          : DateTime.parse(json['uploadedAt'] as String),
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      nextRetryAt: json['nextRetryAt'] == null
          ? null
          : DateTime.parse(json['nextRetryAt'] as String),
    );

Map<String, dynamic> _$UploadStatusToJson(UploadStatus instance) =>
    <String, dynamic>{
      'state': _$UploadStateEnumMap[instance.state]!,
      'progress': instance.progress,
      'error': instance.error,
      'uploadedAt': instance.uploadedAt?.toIso8601String(),
      'retryCount': instance.retryCount,
      'nextRetryAt': instance.nextRetryAt?.toIso8601String(),
    };

const _$UploadStateEnumMap = {
  UploadState.pending: 'pending',
  UploadState.uploading: 'uploading',
  UploadState.completed: 'completed',
  UploadState.failed: 'failed',
  UploadState.cancelled: 'cancelled',
};
