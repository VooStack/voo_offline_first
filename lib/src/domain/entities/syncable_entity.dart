import 'base_entity.dart';
import '../../core/enums/sync_status.dart';

/// Base entity for data that needs to be synchronized
abstract class SyncableEntity extends BaseEntity {
  const SyncableEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.syncStatus,
    this.lastSyncedAt,
    this.isDeleted = false,
    this.syncError,
  });
  final SyncStatus syncStatus;
  final DateTime? lastSyncedAt;
  final bool isDeleted;
  final String? syncError;

  @override
  List<Object?> get props => [
        ...super.props,
        syncStatus,
        lastSyncedAt,
        isDeleted,
        syncError,
      ];
}
