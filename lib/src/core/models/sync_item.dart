import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:voo_offline_first/voo_offline_first.dart';

part 'sync_item.g.dart';

/// Represents an item in the sync queue
@JsonSerializable()
class SyncItem extends Equatable {
  const SyncItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.data,
    required this.createdAt,
    required this.status,
    required this.priority,
    this.endpoint,
    this.lastAttemptAt,
    this.dependencies = const [],
  });

  factory SyncItem.fromJson(Map<String, dynamic> json) => _$SyncItemFromJson(json);

  /// Unique identifier for this sync item
  final String id;

  /// Type of entity being synced (e.g., 'GoodCatch')
  final String entityType;

  /// ID of the entity being synced
  final String entityId;

  /// Serialized data to be synced
  final Map<String, dynamic> data;

  /// When this sync item was created
  final DateTime createdAt;

  /// Current upload status
  final UploadStatus status;

  /// Priority level for this sync operation
  final SyncPriority priority;

  /// API endpoint for syncing (if different from entity default)
  final String? endpoint;

  /// When the last sync attempt was made
  final DateTime? lastAttemptAt;

  /// List of sync item IDs that must be completed before this one
  final List<String> dependencies;

  /// Whether this item is ready to be synced (no pending dependencies)
  bool get isReadyForSync => dependencies.isEmpty;

  /// Whether this item should be retried
  bool get shouldRetry => status.canRetry && (lastAttemptAt == null || DateTime.now().difference(lastAttemptAt!).inMinutes >= 5);

  SyncItem copyWith({
    String? id,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    UploadStatus? status,
    SyncPriority? priority,
    String? endpoint,
    DateTime? lastAttemptAt,
    List<String>? dependencies,
  }) {
    return SyncItem(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      endpoint: endpoint ?? this.endpoint,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      dependencies: dependencies ?? this.dependencies,
    );
  }

  Map<String, dynamic> toJson() => _$SyncItemToJson(this);

  @override
  List<Object?> get props => [
        id,
        entityType,
        entityId,
        data,
        createdAt,
        status,
        priority,
        endpoint,
        lastAttemptAt,
        dependencies,
      ];
}
