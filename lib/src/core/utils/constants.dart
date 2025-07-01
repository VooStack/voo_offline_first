/// Constants used throughout the offline-first package
class OfflineFirstConstants {
  OfflineFirstConstants._();

  // Database
  static const String databaseName = 'offline_first.db';
  static const int databaseVersion = 1;

  // Sync
  static const Duration defaultSyncInterval = Duration(minutes: 5);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 30);

  // Cache
  static const Duration defaultCacheValidity = Duration(hours: 24);

  // Network
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Sync Status Keys
  static const String lastSyncKey = 'last_sync_timestamp';
  static const String syncInProgressKey = 'sync_in_progress';
  static const String pendingSyncCountKey = 'pending_sync_count';
}
