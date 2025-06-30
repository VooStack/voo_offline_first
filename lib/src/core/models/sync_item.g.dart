// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncItem _$SyncItemFromJson(Map<String, dynamic> json) => $checkedCreate(
      'SyncItem',
      json,
      ($checkedConvert) {
        final val = SyncItem(
          id: $checkedConvert('id', (v) => v as String),
          entityType: $checkedConvert('entityType', (v) => v as String),
          entityId: $checkedConvert('entityId', (v) => v as String),
          data: $checkedConvert('data', (v) => v as Map<String, dynamic>),
          createdAt:
              $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
          status: $checkedConvert('status',
              (v) => UploadStatus.fromJson(v as Map<String, dynamic>)),
          priority: $checkedConvert(
              'priority', (v) => $enumDecode(_$SyncPriorityEnumMap, v)),
          endpoint: $checkedConvert('endpoint', (v) => v as String?),
          lastAttemptAt: $checkedConvert('lastAttemptAt',
              (v) => v == null ? null : DateTime.parse(v as String)),
          dependencies: $checkedConvert(
              'dependencies',
              (v) =>
                  (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                  const []),
        );
        return val;
      },
    );

Map<String, dynamic> _$SyncItemToJson(SyncItem instance) => <String, dynamic>{
      'id': instance.id,
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'data': instance.data,
      'createdAt': instance.createdAt.toIso8601String(),
      'status': instance.status.toJson(),
      'priority': _$SyncPriorityEnumMap[instance.priority]!,
      'endpoint': instance.endpoint,
      'lastAttemptAt': instance.lastAttemptAt?.toIso8601String(),
      'dependencies': instance.dependencies,
    };

const _$SyncPriorityEnumMap = {
  SyncPriority.low: 'low',
  SyncPriority.normal: 'normal',
  SyncPriority.high: 'high',
  SyncPriority.critical: 'critical',
};
