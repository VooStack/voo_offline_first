import '../models/base_model.dart';
import '../../domain/entities/base_entity.dart';
import '../../core/utils/typedef.dart';

/// Base interface for remote data sources
abstract class RemoteDataSource<T extends BaseEntity, M extends BaseModel<T>> {
  /// Fetch all items from server
  Future<List<M>> fetchAll();

  /// Fetch item by ID
  Future<M> fetchById(String id);

  /// Create item on server
  Future<M> create(DataMap data);

  /// Update item on server
  Future<M> update(String id, DataMap data);

  /// Delete item on server
  Future<void> delete(String id);

  /// Batch create items
  Future<List<M>> batchCreate(List<DataMap> data);

  /// Batch update items
  Future<List<M>> batchUpdate(List<DataMap> data);

  /// Batch delete items
  Future<void> batchDelete(List<String> ids);

  /// Fetch items with pagination
  Future<List<M>> fetchPaginated({
    required int page,
    required int pageSize,
    Map<String, dynamic>? filters,
  });

  /// Search items on server
  Future<List<M>> search(String query, {Map<String, dynamic>? filters});

  /// Sync changes to server
  Future<List<M>> sync(List<M> models);

  /// Fetch changes since last sync
  Future<List<M>> fetchChangesSince(DateTime lastSync);
}
