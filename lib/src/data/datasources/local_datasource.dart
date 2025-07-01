import '../models/base_model.dart';
import '../../domain/entities/base_entity.dart';

/// Base interface for local data sources
abstract class LocalDataSource<T extends BaseEntity, M extends BaseModel<T>> {
  /// Get all items from local storage
  Future<List<M>> getAll();

  /// Get item by ID
  Future<M?> getById(String id);

  /// Save item to local storage
  Future<M> save(M model);

  /// Save multiple items
  Future<List<M>> saveAll(List<M> models);

  /// Update item in local storage
  Future<M> update(M model);

  /// Delete item from local storage
  Future<void> delete(String id);

  /// Delete multiple items
  Future<void> deleteAll(List<String> ids);

  /// Clear all items
  Future<void> clearAll();

  /// Check if item exists
  Future<bool> exists(String id);

  /// Get items with pagination
  Future<List<M>> getPaginated({
    required int offset,
    required int limit,
  });

  /// Search items
  Future<List<M>> search(String query);

  /// Get count of items
  Future<int> count();

  /// Watch changes to the data
  Stream<List<M>> watchAll();

  /// Watch changes to a specific item
  Stream<M?> watchById(String id);
}
