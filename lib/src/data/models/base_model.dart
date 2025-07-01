import 'package:json_annotation/json_annotation.dart';
import '../../core/utils/typedef.dart';
import '../../domain/entities/base_entity.dart';

/// Base model class that all data models should extend
abstract class BaseModel<T extends BaseEntity> {
  const BaseModel();

  /// Convert model to JSON
  DataMap toJson();

  /// Convert model to entity
  T toEntity();

  /// Convert model to database companion
  dynamic toCompanion();
}

/// DateTime converter for JSON serialization
class DateTimeConverter implements JsonConverter<DateTime, String> {
  const DateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toIso8601String();
}

/// Nullable DateTime converter for JSON serialization
class NullableDateTimeConverter implements JsonConverter<DateTime?, String?> {
  const NullableDateTimeConverter();

  @override
  DateTime? fromJson(String? json) => json != null ? DateTime.parse(json) : null;

  @override
  String? toJson(DateTime? object) => object?.toIso8601String();
}
