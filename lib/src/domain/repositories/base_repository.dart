import '../../core/utils/typedef.dart';
import '../entities/base_entity.dart';

/// Base repository interface that all repositories should extend
abstract class BaseRepository<T extends BaseEntity> {
  /// Get all entities
  ResultFuture<List<T>> getAll();

  /// Get entity by ID
  ResultFuture<T> getById(String id);

  /// Create a new entity
  ResultFuture<T> create(T entity);

  /// Update an existing entity
  ResultFuture<T> update(T entity);

  /// Delete an entity
  ResultVoid delete(String id);

  /// Check if entity exists
  ResultFuture<bool> exists(String id);

  /// Get entities with pagination
  ResultFuture<List<T>> getPaginated({
    required int page,
    required int pageSize,
  });

  /// Search entities
  ResultFuture<List<T>> search(String query);

  /// Clear all entities
  ResultVoid clearAll();
}
