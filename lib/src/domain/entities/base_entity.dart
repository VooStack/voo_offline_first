import 'package:equatable/equatable.dart';

/// Base entity class that all domain entities should extend
abstract class BaseEntity extends Equatable {
  const BaseEntity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, createdAt, updatedAt];
}
