import 'package:json_annotation/json_annotation.dart';
import 'package:voo_offline_first/src/core/enums/sync_status.dart';
import '../../domain/entities/syncable_entity.dart';
import 'base_model.dart';

/// Base model for syncable data
abstract class SyncableModel<T extends SyncableEntity> extends BaseModel<T> {
  const SyncableModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    this.lastSyncedAt,
    this.isDeleted = false,
    this.syncError,
  });
  final String id;
  @DateTimeConverter()
  final DateTime createdAt;
  @DateTimeConverter()
  final DateTime updatedAt;
  final SyncStatus syncStatus;
  @NullableDateTimeConverter()
  final DateTime? lastSyncedAt;
  final bool isDeleted;
  final String? syncError;

  /// Create a copy with updated sync status
  SyncableModel<T> copyWithSyncStatus({
    SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    String? syncError,
  });

  /// Mark as deleted
  SyncableModel<T> markAsDeleted() {
    return copyWithSyncStatus(
      syncStatus: SyncStatus.pending,
    );
  }

  /// Check if needs sync
  bool get needsSync => syncStatus == SyncStatus.pending || syncStatus == SyncStatus.error;
}

/// JSON converter for SyncStatus enum
class SyncStatusConverter implements JsonConverter<SyncStatus, int> {
  const SyncStatusConverter();

  @override
  SyncStatus fromJson(int json) => SyncStatus.values[json];

  @override
  int toJson(SyncStatus object) => object.index;
}
