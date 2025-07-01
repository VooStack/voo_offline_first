import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

import '../core/interfaces/offline_repository.dart';
import '../core/interfaces/sync_manager.dart';
import '../core/models/sync_item.dart';
import '../core/models/upload_status.dart';
import '../database/sync_database.dart';
import '../annotations/offline_entity.dart';
import '../core/exceptions/offline_exceptions.dart';

/// Base implementation of OfflineRepository that provides common functionality
///
/// Extend this class and implement the abstract methods to create a repository
/// for your specific entity type.
abstract class BaseOfflineRepository<T> implements OfflineRepository<T> {
  BaseOfflineRepository({
    required this.database,
    required this.syncManager,
    required this.entityType,
    required this.offlineEntity,
  });

  final SyncDatabase database;
  final SyncManager syncManager;
  final String entityType;
  final OfflineEntity offlineEntity;

  static const _uuid = Uuid();

  // Abstract methods that must be implemented by subclasses

  /// Convert entity to JSON for storage
  Map<String, dynamic> toJson(T entity);

  /// Convert JSON to entity
  T fromJson(Map<String, dynamic> json);

  /// Get the ID of an entity
  String getId(T entity);

  /// Set the ID of an entity (used when creating new entities)
  T setId(T entity, String id);

  /// Get the table name for this entity type
  String get tableName;

  /// Insert entity into the specific table
  Future<void> insertEntity(T entity);

  /// Update entity in the specific table
  Future<void> updateEntity(T entity);

  /// Delete entity from the specific table
  Future<void> deleteEntityById(String id);

  /// Get entity from the specific table
  Future<T?> getEntityById(String id);

  /// Get all entities from the specific table
  Future<List<T>> getAllEntities();

  /// Get entities matching criteria from the specific table
  Future<List<T>> getEntitiesWhere(Map<String, dynamic> criteria);

  /// Watch all entities from the specific table
  Stream<List<T>> watchAllEntities();

  /// Watch entities matching criteria from the specific table
  Stream<List<T>> watchEntitiesWhere(Map<String, dynamic> criteria);

  // Implemented methods from OfflineRepository interface

  @override
  Future<List<T>> getAll() async {
    try {
      return await getAllEntities();
    } catch (e) {
      throw DatabaseException(
        'Failed to get all entities: $e',
        tableName: offlineEntity.tableName,
        operation: 'select',
      );
    }
  }

  @override
  Future<List<T>> getWhere(Map<String, dynamic> criteria) async {
    try {
      return await getEntitiesWhere(criteria);
    } catch (e) {
      throw DatabaseException(
        'Failed to get entities with criteria: $e',
        tableName: offlineEntity.tableName,
        operation: 'select',
      );
    }
  }

  @override
  Future<T?> getById(String id) async {
    try {
      if (id.isEmpty) {
        throw ValidationException('Entity ID cannot be empty', fieldName: 'id');
      }
      return await getEntityById(id);
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw DatabaseException(
        'Failed to get entity by ID: $e',
        tableName: offlineEntity.tableName,
        operation: 'select',
      );
    }
  }

  @override
  Future<T> save(T entity) async {
    try {
      final id = getId(entity);
      final entityIsNew = id.isEmpty;

      final entityWithId = entityIsNew ? setId(entity, _uuid.v4()) : entity;
      final finalId = getId(entityWithId);

      // Start transaction for consistency
      return await database.transaction(() async {
        if (entityIsNew) {
          await insertEntity(entityWithId);
          await _createEntityMetadata(finalId, isNew: true);
        } else {
          await updateEntity(entityWithId);
          await _updateEntityMetadata(finalId);
        }

        // Queue for sync if auto-sync is enabled
        if (offlineEntity.autoSync) {
          await queueForSync(finalId);
        }

        return entityWithId;
      });
    } catch (e) {
      if (e is ValidationException || e is SerializationException) rethrow;
      final id = getId(entity);
      final entityIsNew = id.isEmpty;
      throw DatabaseException(
        'Failed to save entity: $e',
        tableName: offlineEntity.tableName,
        operation: entityIsNew ? 'insert' : 'update',
      );
    }
  }

  @override
  Future<List<T>> saveAll(List<T> entities) async {
    if (entities.isEmpty) return [];

    try {
      return await database.transaction(() async {
        final savedEntities = <T>[];
        for (final entity in entities) {
          savedEntities.add(await save(entity));
        }
        return savedEntities;
      });
    } catch (e) {
      throw DatabaseException(
        'Failed to save multiple entities: $e',
        tableName: offlineEntity.tableName,
        operation: 'batch_insert',
      );
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      if (id.isEmpty) {
        throw ValidationException('Entity ID cannot be empty', fieldName: 'id');
      }

      await database.transaction(() async {
        await deleteEntityById(id);
        await _deleteEntityMetadata(id);
        await syncManager.cancelSyncItem('${entityType}_$id');
      });
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw DatabaseException(
        'Failed to delete entity: $e',
        tableName: offlineEntity.tableName,
        operation: 'delete',
      );
    }
  }

  @override
  Future<void> deleteAll(List<String> ids) async {
    if (ids.isEmpty) return;

    try {
      await database.transaction(() async {
        for (final id in ids) {
          await delete(id);
        }
      });
    } catch (e) {
      throw DatabaseException(
        'Failed to delete multiple entities: $e',
        tableName: offlineEntity.tableName,
        operation: 'batch_delete',
      );
    }
  }

  @override
  Future<List<T>> getPendingSync() async {
    try {
      // Get entities that need sync from metadata using custom SQL
      final metadataResults = await database.customSelect(
        'SELECT entity_id FROM entity_metadata WHERE entity_type = ? AND needs_sync = 1',
        variables: [Variable.withString(entityType)],
      ).get();

      final entityIds = metadataResults.map((m) => m.data['entity_id'] as String).toList();

      if (entityIds.isEmpty) return [];

      // Get the actual entities
      final entities = <T>[];
      for (final id in entityIds) {
        final entity = await getById(id);
        if (entity != null) {
          entities.add(entity);
        }
      }

      return entities;
    } catch (e) {
      throw DatabaseException(
        'Failed to get pending sync entities: $e',
        tableName: 'entity_metadata',
        operation: 'select',
      );
    }
  }

  @override
  Future<void> markAsUploaded(String id) async {
    try {
      await _updateEntityMetadata(id, lastSyncedAt: DateTime.now(), needsSync: false);
      await updateUploadStatus(id, const UploadStatus(state: UploadState.completed));
    } catch (e) {
      throw DatabaseException(
        'Failed to mark entity as uploaded: $e',
        tableName: 'entity_metadata',
        operation: 'update',
      );
    }
  }

  @override
  Future<void> updateUploadStatus(String id, UploadStatus status) async {
    try {
      // Store upload status in entity metadata as JSON using custom SQL
      await database.customUpdate(
        'UPDATE entity_metadata SET sync_status = ?, updated_at = ? WHERE entity_type = ? AND entity_id = ?',
        variables: [
          Variable.withString(jsonEncode(status.toJson())),
          Variable.withDateTime(DateTime.now()),
          Variable.withString(entityType),
          Variable.withString(id),
        ],
      );
    } catch (e) {
      throw DatabaseException(
        'Failed to update upload status: $e',
        tableName: 'entity_metadata',
        operation: 'update',
      );
    }
  }

  @override
  Future<void> queueForSync(String id) async {
    try {
      final entity = await getById(id);
      if (entity == null) {
        throw ValidationException('Entity not found for sync queue', fieldName: 'id', value: id);
      }

      final syncItem = SyncItem(
        id: '${entityType}_$id',
        entityType: entityType,
        entityId: id,
        data: toJson(entity),
        createdAt: DateTime.now(),
        status: const UploadStatus(state: UploadState.pending),
        priority: offlineEntity.syncPriority,
        endpoint: offlineEntity.endpoint,
      );

      await syncManager.queueForSync(syncItem);
      await _updateEntityMetadata(id, needsSync: true);
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw SyncException(
        'Failed to queue entity for sync: $e',
        entityType: entityType,
        entityId: id,
      );
    }
  }

  @override
  Future<void> removeFromSyncQueue(String id) async {
    try {
      await syncManager.cancelSyncItem('${entityType}_$id');
      await _updateEntityMetadata(id, needsSync: false);
    } catch (e) {
      throw SyncException(
        'Failed to remove entity from sync queue: $e',
        entityType: entityType,
        entityId: id,
      );
    }
  }

  @override
  Stream<List<T>> watchAll() {
    try {
      return watchAllEntities();
    } catch (e) {
      return Stream.error(DatabaseException(
        'Failed to watch all entities: $e',
        tableName: offlineEntity.tableName,
        operation: 'watch',
      ));
    }
  }

  @override
  Stream<List<T>> watchWhere(Map<String, dynamic> criteria) {
    try {
      return watchEntitiesWhere(criteria);
    } catch (e) {
      return Stream.error(DatabaseException(
        'Failed to watch entities with criteria: $e',
        tableName: offlineEntity.tableName,
        operation: 'watch',
      ));
    }
  }

  @override
  Stream<List<SyncItem>> watchPendingSync() {
    try {
      // Use polling instead of real-time watching
      return Stream.periodic(const Duration(seconds: 2)).asyncMap((_) async {
        final results = await database.customSelect(
          'SELECT * FROM sync_items WHERE entity_type = ? AND status LIKE \'%"state":"pending"%\'',
          variables: [Variable.withString(entityType)],
        ).get();

        return results.map((row) => _convertRowToSyncItem(row.data)).where((item) => item.status.isPending).toList();
      });
    } catch (e) {
      return Stream.error(SyncException(
        'Failed to watch pending sync items: $e',
        entityType: entityType,
      ));
    }
  }

  @override
  Stream<UploadStatus?> watchUploadStatus(String id) {
    try {
      return Stream.periodic(const Duration(seconds: 2)).asyncMap((_) async {
        final result = await database.customSelect(
          'SELECT sync_status FROM entity_metadata WHERE entity_type = ? AND entity_id = ?',
          variables: [Variable.withString(entityType), Variable.withString(id)],
        ).getSingleOrNull();

        if (result == null) return null;

        try {
          final statusJson = jsonDecode(result.data['sync_status'] as String) as Map<String, dynamic>;
          return UploadStatus.fromJson(statusJson);
        } catch (e) {
          return const UploadStatus(state: UploadState.pending);
        }
      }).handleError((e) => null);
    } catch (e) {
      return Stream.error(DatabaseException(
        'Failed to watch upload status: $e',
        tableName: 'entity_metadata',
        operation: 'watch',
      ));
    }
  }

  @override
  Future<int> count() async {
    try {
      final result = await database.customSelect('SELECT COUNT(*) as count FROM ${offlineEntity.tableName}').getSingle();
      return result.data['count'] as int? ?? 0;
    } catch (e) {
      throw DatabaseException(
        'Failed to count entities: $e',
        tableName: offlineEntity.tableName,
        operation: 'count',
      );
    }
  }

  @override
  Future<int> countPendingSync() async {
    try {
      final pending = await getPendingSync();
      return pending.length;
    } catch (e) {
      throw DatabaseException(
        'Failed to count pending sync entities: $e',
        tableName: 'entity_metadata',
        operation: 'count',
      );
    }
  }

  @override
  Future<void> clear() async {
    try {
      await database.transaction(() async {
        // Clear entity data
        await database.customStatement('DELETE FROM ${offlineEntity.tableName}');

        // Clear metadata
        await database.customUpdate(
          'DELETE FROM entity_metadata WHERE entity_type = ?',
          variables: [Variable.withString(entityType)],
        );

        // Clear sync items
        await database.customUpdate(
          'DELETE FROM sync_items WHERE entity_type = ?',
          variables: [Variable.withString(entityType)],
        );
      });
    } catch (e) {
      throw DatabaseException(
        'Failed to clear all entities: $e',
        tableName: offlineEntity.tableName,
        operation: 'delete_all',
      );
    }
  }

  // Protected helper methods for metadata management

  Future<void> _createEntityMetadata(String entityId, {required bool isNew}) async {
    try {
      await database.customInsert(
        '''
        INSERT OR REPLACE INTO entity_metadata 
        (id, entity_type, entity_id, created_at, updated_at, needs_sync, sync_status)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        ''',
        variables: [
          Variable.withString('${entityType}_$entityId'),
          Variable.withString(entityType),
          Variable.withString(entityId),
          Variable.withDateTime(DateTime.now()),
          Variable.withDateTime(DateTime.now()),
          Variable.withBool(isNew && offlineEntity.autoSync),
          Variable.withString('{"state":"pending"}'),
        ],
      );
    } catch (e) {
      throw DatabaseException(
        'Failed to create entity metadata: $e',
        tableName: 'entity_metadata',
        operation: 'insert',
      );
    }
  }

  Future<void> _updateEntityMetadata(
    String entityId, {
    DateTime? lastSyncedAt,
    bool? needsSync,
  }) async {
    try {
      final updates = <String>[];
      final variables = <Variable>[];

      updates.add('updated_at = ?');
      variables.add(Variable.withDateTime(DateTime.now()));

      if (lastSyncedAt != null) {
        updates.add('last_synced_at = ?');
        variables.add(Variable.withDateTime(lastSyncedAt));
      }

      if (needsSync != null) {
        updates.add('needs_sync = ?');
        variables.add(Variable.withBool(needsSync));
      }

      variables.addAll([
        Variable.withString(entityType),
        Variable.withString(entityId),
      ]);

      await database.customUpdate(
        'UPDATE entity_metadata SET ${updates.join(', ')} WHERE entity_type = ? AND entity_id = ?',
        variables: variables,
      );
    } catch (e) {
      throw DatabaseException(
        'Failed to update entity metadata: $e',
        tableName: 'entity_metadata',
        operation: 'update',
      );
    }
  }

  Future<void> _deleteEntityMetadata(String entityId) async {
    try {
      await database.customUpdate(
        'DELETE FROM entity_metadata WHERE entity_type = ? AND entity_id = ?',
        variables: [Variable.withString(entityType), Variable.withString(entityId)],
      );
    } catch (e) {
      throw DatabaseException(
        'Failed to delete entity metadata: $e',
        tableName: 'entity_metadata',
        operation: 'delete',
      );
    }
  }

  SyncItem _convertRowToSyncItem(Map<String, dynamic> data) {
    try {
      final statusJson = jsonDecode(data['status'] as String) as Map<String, dynamic>;
      final dependencies = jsonDecode(data['dependencies'] as String) as List<dynamic>;

      return SyncItem(
        id: data['id'] as String,
        entityType: data['entity_type'] as String,
        entityId: data['entity_id'] as String,
        data: jsonDecode(data['data'] as String) as Map<String, dynamic>,
        createdAt: DateTime.parse(data['created_at'] as String),
        status: UploadStatus.fromJson(statusJson),
        priority: SyncPriority.values.firstWhere(
          (p) => p.value == data['priority'] as int,
          orElse: () => SyncPriority.normal,
        ),
        endpoint: data['endpoint'] as String?,
        lastAttemptAt: data['last_attempt_at'] != null ? DateTime.parse(data['last_attempt_at'] as String) : null,
        dependencies: dependencies.cast<String>(),
      );
    } catch (e) {
      throw SerializationException(
        'Failed to convert sync item data: $e',
        entityType: entityType,
        operation: 'deserialize',
      );
    }
  }
}
