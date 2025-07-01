import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
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
        // Add migration logic here for future schema changes
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        await customStatement('PRAGMA journal_mode = WAL');
      },
    );
  }

  Future<void> _insertDefaultConfigs() async {
    try {
      // Use a simple insert statement to avoid getter issues
      await customInsert(
        '''
        INSERT OR IGNORE INTO sync_configs 
        (entity_type, endpoint, auto_sync, max_retries, retry_delay_seconds, batch_size, sync_fields, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        variables: [
          Variable.withString('default'),
          const Variable(null),
          Variable.withBool(true),
          Variable.withInt(3),
          Variable.withInt(300),
          Variable.withInt(10),
          Variable.withString('[]'),
          Variable.withDateTime(DateTime.now()),
          Variable.withDateTime(DateTime.now()),
        ],
      );
    } catch (e) {
      debugPrint('Warning: Failed to insert default configs: $e');
    }
  }

  // Basic CRUD operations using custom SQL to avoid getter issues

  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    final results = await customSelect(
      '''
      SELECT * FROM sync_items 
      WHERE status LIKE '%"state":"pending"%' 
      ORDER BY priority DESC, created_at ASC
      ''',
    ).get();

    return results.map((row) => row.data).toList();
  }

  Future<List<Map<String, dynamic>>> getSyncItemsByEntityType(String entityType) async {
    final results = await customSelect(
      '''
      SELECT * FROM sync_items 
      WHERE entity_type = ? 
      ORDER BY priority DESC, created_at ASC
      ''',
      variables: [Variable.withString(entityType)],
    ).get();

    return results.map((row) => row.data).toList();
  }

  Future<List<Map<String, dynamic>>> getRetryReadySyncItems() async {
    final cutoffTime = DateTime.now().subtract(const Duration(minutes: 5));
    final results = await customSelect(
      '''
      SELECT * FROM sync_items 
      WHERE status LIKE '%"state":"failed"%' 
      AND last_attempt_at < ?
      ''',
      variables: [Variable.withDateTime(cutoffTime)],
    ).get();

    return results.map((row) => row.data).toList();
  }

  Future<int> cleanupOldSyncItems({Duration olderThan = const Duration(days: 7)}) async {
    final cutoffDate = DateTime.now().subtract(olderThan);

    return await customUpdate(
      '''
      DELETE FROM sync_items 
      WHERE status LIKE '%"state":"completed"%' 
      AND created_at < ?
      ''',
      variables: [Variable.withDateTime(cutoffDate)],
    );
  }

  Future<Map<String, dynamic>?> getEntityMetadata(String entityType, String entityId) async {
    final result = await customSelect(
      'SELECT * FROM entity_metadata WHERE entity_type = ? AND entity_id = ?',
      variables: [
        Variable.withString(entityType),
        Variable.withString(entityId),
      ],
    ).getSingleOrNull();

    return result?.data;
  }

  Future<List<Map<String, dynamic>>> getEntitiesNeedingSync(String entityType) async {
    final results = await customSelect(
      '''
      SELECT * FROM entity_metadata 
      WHERE entity_type = ? AND needs_sync = 1 
      ORDER BY updated_at ASC
      ''',
      variables: [Variable.withString(entityType)],
    ).get();

    return results.map((row) => row.data).toList();
  }

  Future<List<Map<String, dynamic>>> getFileSyncItems(String entityId, String entityType) async {
    final results = await customSelect(
      'SELECT * FROM file_sync_items WHERE entity_id = ? AND entity_type = ?',
      variables: [
        Variable.withString(entityId),
        Variable.withString(entityType),
      ],
    ).get();

    return results.map((row) => row.data).toList();
  }

  Future<List<Map<String, dynamic>>> getPendingFileUploads() async {
    final results = await customSelect(
      '''
      SELECT * FROM file_sync_items 
      WHERE upload_status LIKE '%"state":"pending"%' 
      ORDER BY created_at ASC
      ''',
    ).get();

    return results.map((row) => row.data).toList();
  }

  Future<void> updateFileUploadStatus(String fileId, String status) async {
    await customUpdate(
      'UPDATE file_sync_items SET upload_status = ? WHERE id = ?',
      variables: [
        Variable.withString(status),
        Variable.withString(fileId),
      ],
    );
  }

  Future<Map<String, dynamic>> getSyncStatistics() async {
    final total = await customSelect('SELECT COUNT(*) as count FROM sync_items').getSingle();
    final completed = await customSelect('SELECT COUNT(*) as count FROM sync_items WHERE status LIKE \'%"state":"completed"%\'').getSingle();
    final failed = await customSelect('SELECT COUNT(*) as count FROM sync_items WHERE status LIKE \'%"state":"failed"%\'').getSingle();
    final pending = await customSelect('SELECT COUNT(*) as count FROM sync_items WHERE status LIKE \'%"state":"pending"%\'').getSingle();

    return {
      'total': total.data['count'] ?? 0,
      'completed': completed.data['count'] ?? 0,
      'failed': failed.data['count'] ?? 0,
      'pending': pending.data['count'] ?? 0,
    };
  }

  Stream<List<Map<String, dynamic>>> watchSyncQueue() {
    // Use Stream.periodic for polling since customSelectStream doesn't exist
    return Stream.periodic(const Duration(seconds: 2)).asyncMap((_) async {
      final results = await customSelect('SELECT * FROM sync_items ORDER BY priority DESC, created_at ASC').get();
      return results.map((row) => row.data).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> watchEntityMetadata(String entityType) {
    // Use Stream.periodic for polling
    return Stream.periodic(const Duration(seconds: 2)).asyncMap((_) async {
      final results = await customSelect(
        'SELECT * FROM entity_metadata WHERE entity_type = ?',
        variables: [Variable.withString(entityType)],
      ).get();
      return results.map((row) => row.data).toList();
    });
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
      final syncItemsData = await customSelect('SELECT * FROM sync_items LIMIT 100').get();
      final metadataData = await customSelect('SELECT * FROM entity_metadata LIMIT 100').get();
      final configsData = await customSelect('SELECT * FROM sync_configs').get();
      final filesData = await customSelect('SELECT * FROM file_sync_items LIMIT 100').get();

      return {
        'sync_items': syncItemsData
            .map(
              (row) => {
                'id': row.data['id'],
                'entity_type': row.data['entity_type'],
                'entity_id': row.data['entity_id'],
                'created_at': row.data['created_at']?.toString(),
                'status': row.data['status'],
                'priority': row.data['priority'],
              },
            )
            .toList(),
        'metadata': metadataData
            .map(
              (row) => {
                'id': row.data['id'],
                'entity_type': row.data['entity_type'],
                'entity_id': row.data['entity_id'],
                'needs_sync': row.data['needs_sync'],
                'sync_status': row.data['sync_status'],
                'created_at': row.data['created_at']?.toString(),
                'updated_at': row.data['updated_at']?.toString(),
              },
            )
            .toList(),
        'configs': configsData
            .map(
              (row) => {
                'entity_type': row.data['entity_type'],
                'auto_sync': row.data['auto_sync'],
                'max_retries': row.data['max_retries'],
                'batch_size': row.data['batch_size'],
              },
            )
            .toList(),
        'files': filesData
            .map(
              (row) => {
                'id': row.data['id'],
                'entity_id': row.data['entity_id'],
                'file_name': row.data['file_name'],
                'file_size': row.data['file_size'],
                'upload_status': row.data['upload_status'],
              },
            )
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
  // ignore: avoid_print
  print(message);
}
