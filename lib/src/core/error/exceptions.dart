/// Exception classes for the offline-first package
class ServerException implements Exception {
  const ServerException({this.message, this.statusCode});
  final String? message;
  final int? statusCode;

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class CacheException implements Exception {
  const CacheException({this.message});
  final String? message;

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  const NetworkException({this.message});
  final String? message;

  @override
  String toString() => 'NetworkException: $message';
}

class SyncException implements Exception {
  const SyncException({this.message, this.entityId});
  final String? message;
  final String? entityId;

  @override
  String toString() => 'SyncException: $message (Entity: $entityId)';
}

class DatabaseException implements Exception {
  const DatabaseException({this.message});
  final String? message;

  @override
  String toString() => 'DatabaseException: $message';
}
