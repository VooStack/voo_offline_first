import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'database_config.dart';
import '../enums/sync_status.dart';

/// Base Drift database class that applications should extend
abstract class OfflineFirstDatabase extends GeneratedDatabase {
  OfflineFirstDatabase(this.config) : super(_openConnection(config.name));
  final DatabaseConfig config;

  @override
  int get schemaVersion => config.schemaVersion;

  @override
  MigrationStrategy get migration => config.migrationStrategy ?? MigrationStrategy();

  @override
  List<TableInfo> get allTables => config.tables;

  /// Open a database connection
  static LazyDatabase _openConnection(String dbName) {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, dbName));

      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }

      return NativeDatabase.createInBackground(file);
    });
  }
}

/// Base table for syncable entities
@DataClassName('SyncableTableData')
class SyncableTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get syncStatus => intEnum<SyncStatus>()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get syncError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
