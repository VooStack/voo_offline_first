// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncItem _$SyncItemFromJson(Map<String, dynamic> json) => SyncItem(
      id: json['id'] as String,
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      data: json['data'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: UploadStatus.fromJson(json['status'] as Map<String, dynamic>),
      priority: $enumDecode(_$SyncPriorityEnumMap, json['priority']),
      endpoint: json['endpoint'] as String?,
      lastAttemptAt: json['lastAttemptAt'] == null
          ? null
          : DateTime.parse(json['lastAttemptAt'] as String),
      dependencies: (json['dependencies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
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
