import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'tables.dart';

part 'sync_database.g.dart';

@DriftDatabase(
  tables: [
    SyncItems,
    EntityMetadataTable,
    FileSyncItems,
    SyncConfigs,
  ],
)
class SyncDatabase extends _$SyncDatabase {
  SyncDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _insertDefaultConfigs();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {}
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        await customStatement('PRAGMA journal_mode = WAL');
      },
    );
  }

  Future<void> _insertDefaultConfigs() async {
    try {
      await into(syncConfigs).insert(
        SyncConfigsCompanion.insert(
          entityType: 'default',
          endpoint: const Value(null),
          autoSync: const Value(true),
          maxRetries: const Value(3),
          retryDelaySeconds: const Value(300),
          batchSize: const Value(10),
          syncFields: '[]',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    } catch (e) {
      debugPrint('Warning: Failed to insert default configs: $e');
    }
  }

  Future<SyncConfigData?> getSyncConfig(String entityType) async {
    final query = select(syncConfigs)..where((tbl) => tbl.entityType.equals(entityType));

    final result = await query.getSingleOrNull();

    if (result == null) {
      final defaultQuery = select(syncConfigs)..where((tbl) => tbl.entityType.equals('default'));
      return await defaultQuery.getSingleOrNull();
    }

    return result;
  }

  Future<void> updateSyncConfig(SyncConfigData config) async {
    await into(syncConfigs).insert(
      config.toCompanion(true),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<List<SyncItemData>> getPendingSyncItems() async {
    final query = select(syncItems)
      ..where((tbl) => tbl.status.contains('"state":"pending"'))
      ..orderBy([
        (tbl) => OrderingTerm.desc(tbl.priority),
        (tbl) => OrderingTerm.asc(tbl.createdAt),
      ]);

    return await query.get();
  }

  Future<List<SyncItemData>> getSyncItemsByEntityType(String entityType) async {
    final query = select(syncItems)
      ..where((tbl) => tbl.entityType.equals(entityType))
      ..orderBy([
        (tbl) => OrderingTerm.desc(tbl.priority),
        (tbl) => OrderingTerm.asc(tbl.createdAt),
      ]);

    return await query.get();
  }

  Future<List<SyncItemData>> getRetryReadySyncItems() async {
    final cutoffTime = DateTime.now().subtract(const Duration(minutes: 5));
    final query = select(syncItems)..where((tbl) => tbl.status.contains('"state":"failed"') & tbl.lastAttemptAt.isSmallerThanValue(cutoffTime));

    return await query.get();
  }

  Future<int> cleanupOldSyncItems({Duration olderThan = const Duration(days: 7)}) async {
    final cutoffDate = DateTime.now().subtract(olderThan);

    final deleteQuery = delete(syncItems)..where((tbl) => tbl.status.contains('"state":"completed"') & tbl.createdAt.isSmallerThanValue(cutoffDate));

    return await deleteQuery.go();
  }

  Future<EntityMetadata?> getEntityMetadata(String entityType, String entityId) async {
    final query = select(entityMetadataTable)..where((tbl) => tbl.entityType.equals(entityType) & tbl.entityId.equals(entityId));

    return await query.getSingleOrNull();
  }

  Future<List<EntityMetadata>> getEntitiesNeedingSync(String entityType) async {
    final query = select(entityMetadataTable)
      ..where((tbl) => tbl.entityType.equals(entityType) & tbl.needsSync.equals(true))
      ..orderBy([
        (tbl) => OrderingTerm.asc(tbl.updatedAt),
      ]);

    return await query.get();
  }

  Future<List<FileSyncData>> getFileSyncItems(String entityId, String entityType) async {
    final query = select(fileSyncItems)..where((tbl) => tbl.entityId.equals(entityId) & tbl.entityType.equals(entityType));

    return await query.get();
  }

  Future<List<FileSyncData>> getPendingFileUploads() async {
    final query = select(fileSyncItems)
      ..where((tbl) => tbl.uploadStatus.contains('"state":"pending"'))
      ..orderBy([
        (tbl) => OrderingTerm.asc(tbl.createdAt),
      ]);

    return await query.get();
  }

  Future<void> updateFileUploadStatus(String fileId, String status) async {
    await (update(fileSyncItems)..where((tbl) => tbl.id.equals(fileId))).write(
      FileSyncItemsCompanion(
        uploadStatus: Value(status),
      ),
    );
  }

  Future<Map<String, dynamic>> getSyncStatistics() async {
    final totalQuery = selectOnly(syncItems)..addColumns([syncItems.id.count()]);
    final total = await totalQuery.getSingle();

    final completedQuery = selectOnly(syncItems)
      ..addColumns([syncItems.id.count()])
      ..where(syncItems.status.contains('"state":"completed"'));
    final completed = await completedQuery.getSingle();

    final failedQuery = selectOnly(syncItems)
      ..addColumns([syncItems.id.count()])
      ..where(syncItems.status.contains('"state":"failed"'));
    final failed = await failedQuery.getSingle();

    final pendingQuery = selectOnly(syncItems)
      ..addColumns([syncItems.id.count()])
      ..where(syncItems.status.contains('"state":"pending"'));
    final pending = await pendingQuery.getSingle();

    return {
      'total': total.read(syncItems.id.count()) ?? 0,
      'completed': completed.read(syncItems.id.count()) ?? 0,
      'failed': failed.read(syncItems.id.count()) ?? 0,
      'pending': pending.read(syncItems.id.count()) ?? 0,
    };
  }

  Stream<List<SyncItemData>> watchSyncQueue() {
    return select(syncItems).watch();
  }

  Stream<List<EntityMetadata>> watchEntityMetadata(String entityType) {
    return (select(entityMetadataTable)..where((tbl) => tbl.entityType.equals(entityType))).watch();
  }

  Future<void> performMaintenance() async {
    try {
      final cleaned = await cleanupOldSyncItems();
      debugPrint('Cleaned up $cleaned old sync items');

      await customStatement('VACUUM');

      await customStatement('ANALYZE');

      debugPrint('Database maintenance completed');
    } catch (e) {
      debugPrint('Database maintenance failed: $e');
    }
  }

  Future<Map<String, dynamic>> exportDebugData() async {
    try {
      final syncItemsData = await select(syncItems).get();
      final metadataData = await select(entityMetadataTable).get();
      final configsData = await select(syncConfigs).get();
      final filesData = await select(fileSyncItems).get();

      return {
        'sync_items': syncItemsData
            .map((item) => {
                  'id': item.id,
                  'entity_type': item.entityType,
                  'entity_id': item.entityId,
                  'created_at': item.createdAt.toIso8601String(),
                  'status': item.status,
                  'priority': item.priority,
                })
            .toList(),
        'metadata': metadataData
            .map((meta) => {
                  'id': meta.id,
                  'entity_type': meta.entityType,
                  'entity_id': meta.entityId,
                  'needs_sync': meta.needsSync,
                  'sync_status': meta.syncStatus,
                  'created_at': meta.createdAt.toIso8601String(),
                  'updated_at': meta.updatedAt.toIso8601String(),
                })
            .toList(),
        'configs': configsData
            .map((config) => {
                  'entity_type': config.entityType,
                  'auto_sync': config.autoSync,
                  'max_retries': config.maxRetries,
                  'batch_size': config.batchSize,
                })
            .toList(),
        'files': filesData
            .map((file) => {
                  'id': file.id,
                  'entity_id': file.entityId,
                  'file_name': file.fileName,
                  'file_size': file.fileSize,
                  'upload_status': file.uploadStatus,
                })
            .toList(),
      };
    } catch (e) {
      return {'error': 'Failed to export debug data: $e'};
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'offline_sync.db'));

    return NativeDatabase.createInBackground(
      file,
      logStatements: false,
    );
  });
}

void debugPrint(String message) {
  if (const bool.fromEnvironment('dart.vm.product')) {
    return;
  }

  print(message);
}
