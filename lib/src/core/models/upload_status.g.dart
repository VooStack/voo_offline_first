// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadStatus _$UploadStatusFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'UploadStatus',
      json,
      ($checkedConvert) {
        final val = UploadStatus(
          state: $checkedConvert(
              'state', (v) => $enumDecode(_$UploadStateEnumMap, v)),
          progress: $checkedConvert(
              'progress', (v) => (v as num?)?.toDouble() ?? 0.0),
          error: $checkedConvert('error', (v) => v as String?),
          uploadedAt: $checkedConvert('uploadedAt',
              (v) => v == null ? null : DateTime.parse(v as String)),
          retryCount:
              $checkedConvert('retryCount', (v) => (v as num?)?.toInt() ?? 0),
          nextRetryAt: $checkedConvert('nextRetryAt',
              (v) => v == null ? null : DateTime.parse(v as String)),
        );
        return val;
      },
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
