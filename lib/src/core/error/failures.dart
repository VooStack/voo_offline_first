import 'package:equatable/equatable.dart';

/// Base failure class
abstract class Failure extends Equatable {

  const Failure({
    required this.message,
    this.error,
  });
  final String message;
  final dynamic error;

  @override
  List<Object?> get props => [message, error];
}

class ServerFailure extends Failure {

  const ServerFailure({
    required super.message,
    super.error,
    this.statusCode,
  });
  final int? statusCode;

  @override
  List<Object?> get props => [message, error, statusCode];
}

class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.error,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.error,
  });
}

class SyncFailure extends Failure {

  const SyncFailure({
    required super.message,
    super.error,
    this.entityId,
  });
  final String? entityId;

  @override
  List<Object?> get props => [message, error, entityId];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required super.message,
    super.error,
  });
}
