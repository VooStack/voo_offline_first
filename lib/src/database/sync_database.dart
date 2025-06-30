import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'tables.dart';

part 'sync_database.g.dart';

/// Main database class for offline sync functionality
@DriftDatabase(tables: [
  SyncItems,
  EntityMetadataTable,
  FileSyncItems,
  SyncConfigs,
])
class SyncDatabase extends _$SyncDatabase {
  SyncDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _createDefaultSyncConfigs();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future schema migrations here
        if (from < 2) {
          // Example migration for version 2
          // await m.addColumn(syncItems, syncItems.newColumn);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// Create default sync configurations for common entity types
  Future<void> _createDefaultSyncConfigs() async {
    final defaultConfigs = [
      SyncConfigsCompanion.insert(
        entityType: 'GoodCatch',
        endpoint: const Value('/api/good-catches'),
        autoSync: const Value(true),
        maxRetries: const Value(3),
        syncFields: '["images", "location"]',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      // Add more default configs as needed
    ];

    for (final config in defaultConfigs) {
      await into(syncConfigs).insertOnConflictUpdate(config);
    }
  }

  // Sync Items operations
  Future<List<SyncItemData>> getAllSyncItems() => select(syncItems).get();

  Future<List<SyncItemData>> getPendingSyncItems() => (select(syncItems)..where((tbl) => tbl.status.contains('"state":"pending"'))).get();

  Future<List<SyncItemData>> getSyncItemsByPriority(int minPriority) => (select(syncItems)..where((tbl) => tbl.priority.isBiggerOrEqualValue(minPriority))).get();

  Future<SyncItemData?> getSyncItemById(String id) => (select(syncItems)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<int> insertSyncItem(SyncItemsCompanion entry) => into(syncItems).insert(entry);

  Future<bool> updateSyncItem(SyncItemsCompanion entry) => update(syncItems).replace(entry);

  Future<int> deleteSyncItem(String id) => (delete(syncItems)..where((tbl) => tbl.id.equals(id))).go();

  Stream<List<SyncItemData>> watchSyncItems() => select(syncItems).watch();

  Stream<List<SyncItemData>> watchPendingSyncItems() => (select(syncItems)..where((tbl) => tbl.status.contains('"state":"pending"'))).watch();

  // Entity Metadata operations
  Future<EntityMetadata?> getEntityMetadata(String entityType, String entityId) =>
      (select(entityMetadataTable)..where((tbl) => tbl.entityType.equals(entityType) & tbl.entityId.equals(entityId))).getSingleOrNull();

  Future<void> upsertEntityMetadata(EntityMetadataTableCompanion entry) => into(entityMetadataTable).insertOnConflictUpdate(entry);

  Future<List<EntityMetadata>> getEntitiesNeedingSync() => (select(entityMetadataTable)..where((tbl) => tbl.needsSync.equals(true))).get();

  // File Sync operations
  Future<List<FileSyncData>> getFilesForEntity(String entityType, String entityId) =>
      (select(fileSyncItems)..where((tbl) => tbl.entityType.equals(entityType) & tbl.entityId.equals(entityId))).get();

  Future<List<FileSyncData>> getPendingFileUploads() => (select(fileSyncItems)..where((tbl) => tbl.uploadStatus.contains('"state":"pending"'))).get();

  Future<int> insertFileSync(FileSyncItemsCompanion entry) => into(fileSyncItems).insert(entry);

  Future<bool> updateFileSync(FileSyncItemsCompanion entry) => update(fileSyncItems).replace(entry);

  // Sync Config operations
  Future<SyncConfigData?> getSyncConfig(String entityType) => (select(syncConfigs)..where((tbl) => tbl.entityType.equals(entityType))).getSingleOrNull();

  Future<void> upsertSyncConfig(SyncConfigsCompanion entry) => into(syncConfigs).insertOnConflictUpdate(entry);

  // Utility methods
  Future<void> clearCompletedSyncItems() async {
    await (delete(syncItems)..where((tbl) => tbl.status.contains('"state":"completed"'))).go();
  }

  Future<int> getSyncItemCount() async {
    final query = selectOnly(syncItems)..addColumns([syncItems.id.count()]);
    final result = await query.getSingle();
    return result.read(syncItems.id.count()) ?? 0;
  }

  Future<int> getPendingSyncItemCount() async {
    final query = selectOnly(syncItems)
      ..addColumns([syncItems.id.count()])
      ..where(syncItems.status.contains('"state":"pending"'));
    final result = await query.getSingle();
    return result.read(syncItems.id.count()) ?? 0;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Make sure sqlite3 is properly initialized on mobile platforms
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'offline_sync.db'));

    return NativeDatabase.createInBackground(file);
  });
}
