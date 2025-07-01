import 'package:drift/drift.dart';

/// Configuration for the offline-first database
class DatabaseConfig {
  const DatabaseConfig({
    required this.name,
    required this.schemaVersion,
    required this.tables,
    this.migrationStrategy,
  });

  /// Default database configuration
  factory DatabaseConfig.defaults() {
    return DatabaseConfig(
      name: 'offline_first.db',
      schemaVersion: 1,
      tables: [],
      migrationStrategy: MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Handle migrations
        },
      ),
    );
  }
  final String name;
  final int schemaVersion;
  final List<TableInfo> tables;
  final MigrationStrategy? migrationStrategy;
}
