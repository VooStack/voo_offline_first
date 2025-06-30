import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

import '../core/interfaces/offline_repository.dart';
import '../core/interfaces/sync_manager.dart';
import '../core/models/sync_item.dart';
import '../core/models/upload_status.dart';
import '../database/sync_database.dart';
import '../annotations/offline_entity.dart';

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

  /// Get the table for this entity type (your Drift table)
  TableInfo get table;

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
    return await getAllEntities();
  }

  @override
  Future<List<T>> getWhere(Map<String, dynamic> criteria) async {
    return await getEntitiesWhere(criteria);
  }

  @override
  Future<T?> getById(String id) async {
    return await getEntityById(id);
  }

  @override
  Future<T> save(T entity) async {
    final id = getId(entity);
    final isNew = id.isEmpty;

    final entityWithId = isNew ? setId(entity, _uuid.v4()) : entity;
    final finalId = getId(entityWithId);

    if (isNew) {
      await insertEntity(entityWithId);
    } else {
      await updateEntity(entityWithId);
    }

    // Queue for sync if auto-sync is enabled
    if (offlineEntity.autoSync) {
      await queueForSync(finalId);
    }

    return entityWithId;
  }

  @override
  Future<List<T>> saveAll(List<T> entities) async {
    final savedEntities = <T>[];

    for (final entity in entities) {
      savedEntities.add(await save(entity));
    }

    return savedEntities;
  }

  @override
  Future<void> delete(String id) async {
    await deleteEntityById(id);
    await syncManager.cancelSyncItem('${entityType}_$id');
  }

  @override
  Future<void> deleteAll(List<String> ids) async {
    for (final id in ids) {
      await delete(id);
    }
  }

  @override
  Future<List<T>> getPendingSync() async {
    // This will be implemented after code generation
    return [];
  }

  @override
  Future<void> markAsUploaded(String id) async {
    // This will be implemented after code generation
    throw UnimplementedError('Will be implemented after code generation');
  }

  @override
  Future<void> updateUploadStatus(String id, UploadStatus status) async {
    // This will be implemented after code generation
    throw UnimplementedError('Will be implemented after code generation');
  }

  @override
  Future<void> queueForSync(String id) async {
    final entity = await getById(id);
    if (entity == null) return;

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
  }

  @override
  Future<void> removeFromSyncQueue(String id) async {
    await syncManager.cancelSyncItem('${entityType}_$id');
  }

  @override
  Stream<List<T>> watchAll() {
    return watchAllEntities();
  }

  @override
  Stream<List<T>> watchWhere(Map<String, dynamic> criteria) {
    return watchEntitiesWhere(criteria);
  }

  @override
  Stream<List<SyncItem>> watchPendingSync() {
    // This will be implemented after code generation
    return Stream.value([]);
  }

  @override
  Stream<UploadStatus?> watchUploadStatus(String id) {
    // This will be implemented after code generation
    return Stream.value(null);
  }

  @override
  Future<int> count() async {
    // Implement based on your specific table
    throw UnimplementedError('Implement count() in your specific repository');
  }

  @override
  Future<int> countPendingSync() async {
    final pending = await getPendingSync();
    return pending.length;
  }

  @override
  Future<void> clear() async {
    // Implement based on your specific table
    throw UnimplementedError('Implement clear() in your specific repository');
  }
}
