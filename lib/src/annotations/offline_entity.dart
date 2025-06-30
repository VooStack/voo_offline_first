/// Annotation to mark a class as an offline-capable entity
///
/// This annotation is used to identify entities that should have
/// offline functionality with automatic sync capabilities.
///
/// Example:
/// ```dart
/// @OfflineEntity(
///   tableName: 'good_catches',
///   endpoint: '/api/good-catches',
///   syncFields: ['images', 'location'],
/// )
/// class GoodCatch {
///   // ... class implementation
/// }
/// ```
class OfflineEntity {
  const OfflineEntity({
    required this.tableName,
    this.endpoint,
    this.syncFields = const [],
    this.autoSync = true,
    this.maxRetries = 3,
    this.syncPriority = SyncPriority.normal,
  });

  /// The name of the database table for this entity
  final String tableName;

  /// The API endpoint for syncing this entity (optional)
  final String? endpoint;

  /// List of field names that require special sync handling (e.g., file uploads)
  final List<String> syncFields;

  /// Whether this entity should be automatically synced when connectivity is available
  final bool autoSync;

  /// Maximum number of retry attempts for failed syncs
  final int maxRetries;

  /// Priority level for sync operations
  final SyncPriority syncPriority;
}

/// Priority levels for sync operations
enum SyncPriority {
  low(1),
  normal(2),
  high(3),
  critical(4);

  const SyncPriority(this.value);
  final int value;
}
