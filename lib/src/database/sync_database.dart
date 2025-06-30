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
        // Default configs will be added after code generation
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
