import 'package:drift/drift.dart';

/// Table for storing sync queue items
@DataClassName('SyncItemData')
class SyncItems extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get data => text()(); // JSON string
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get status => text()(); // JSON string of UploadStatus
  IntColumn get priority => integer()();
  TextColumn get endpoint => text().nullable()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  TextColumn get dependencies => text()(); // JSON array of string IDs

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Index> get indexes => [
        Index('idx_entity_type_id', [entityType, entityId]),
        Index('idx_priority', [priority]),
        Index('idx_created_at', [createdAt]),
      ];
}

/// Table for storing entity metadata (for tracking sync status)
@DataClassName('EntityMetadata')
class EntityMetadataTable extends Table {
  @override
  String get tableName => 'entity_metadata';

  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get needsSync => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Index> get indexes => [
        Index('idx_entity_type_id_meta', [entityType, entityId]),
        Index('idx_needs_sync', [needsSync]),
        Index('idx_sync_status', [syncStatus]),
      ];
}

/// Table for storing file references and their sync status
@DataClassName('FileSyncData')
class FileSyncItems extends Table {
  TextColumn get id => text()();
  TextColumn get entityId => text()();
  TextColumn get entityType => text()();
  TextColumn get filePath => text()();
  TextColumn get fileName => text()();
  TextColumn get mimeType => text().nullable()();
  IntColumn get fileSize => integer().nullable()();
  TextColumn get checksum => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get uploadStatus => text()(); // JSON string of UploadStatus
  TextColumn get remoteUrl => text().nullable()();
  BoolColumn get isRequired => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Index> get indexes => [
        Index('idx_entity_file', [entityId, entityType]),
        Index('idx_file_path', [filePath]),
      ];
}

/// Table for storing sync configuration per entity type
@DataClassName('SyncConfigData')
class SyncConfigs extends Table {
  TextColumn get entityType => text()();
  TextColumn get endpoint => text().nullable()();
  BoolColumn get autoSync => boolean().withDefault(const Constant(true))();
  IntColumn get maxRetries => integer().withDefault(const Constant(3))();
  IntColumn get retryDelaySeconds => integer().withDefault(const Constant(300))(); // 5 minutes
  IntColumn get batchSize => integer().withDefault(const Constant(10))();
  TextColumn get syncFields => text()(); // JSON array of field names
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {entityType};
}
