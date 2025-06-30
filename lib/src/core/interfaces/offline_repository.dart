import '../models/sync_item.dart';
import '../models/upload_status.dart';

/// Abstract interface for offline-capable repositories
///
/// This interface defines the contract that all offline repositories must implement.
/// It provides methods for CRUD operations as well as sync management.
abstract class OfflineRepository<T> {
  /// Get all entities from local storage
  Future<List<T>> getAll();

  /// Get entities that match the given criteria
  Future<List<T>> getWhere(Map<String, dynamic> criteria);

  /// Get a single entity by its ID
  Future<T?> getById(String id);

  /// Save an entity to local storage
  /// Returns the saved entity with any generated fields populated
  Future<T> save(T entity);

  /// Save multiple entities in a batch operation
  Future<List<T>> saveAll(List<T> entities);

  /// Delete an entity by its ID
  Future<void> delete(String id);

  /// Delete multiple entities by their IDs
  Future<void> deleteAll(List<String> ids);

  /// Get all entities that are pending sync
  Future<List<T>> getPendingSync();

  /// Mark an entity as successfully uploaded
  Future<void> markAsUploaded(String id);

  /// Update the upload status of an entity
  Future<void> updateUploadStatus(String id, UploadStatus status);

  /// Queue an entity for sync
  Future<void> queueForSync(String id);

  /// Remove an entity from the sync queue
  Future<void> removeFromSyncQueue(String id);

  /// Watch all entities (returns a stream for real-time updates)
  Stream<List<T>> watchAll();

  /// Watch entities that match the given criteria
  Stream<List<T>> watchWhere(Map<String, dynamic> criteria);

  /// Watch pending sync items for this repository
  Stream<List<SyncItem>> watchPendingSync();

  /// Watch the upload status of a specific entity
  Stream<UploadStatus?> watchUploadStatus(String id);

  /// Get the total count of entities
  Future<int> count();

  /// Get the count of entities pending sync
  Future<int> countPendingSync();

  /// Clear all local data (use with caution)
  Future<void> clear();
}
