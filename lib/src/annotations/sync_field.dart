import 'package:meta/meta_meta.dart';

/// Annotation to mark fields that require special sync handling
///
/// Use this annotation on fields that contain files, large data,
/// or require custom serialization during sync operations.
///
/// Example:
/// ```dart
/// class GoodCatch {
///   @SyncField(type: SyncFieldType.fileList)
///   final List<String> imagePaths;
///
///   @SyncField(type: SyncFieldType.json, compress: true)
///   final Map<String, dynamic> metadata;
/// }
/// ```
@Target({TargetKind.field})
class SyncField {
  const SyncField({
    required this.type,
    this.compress = false,
    this.encrypt = false,
    this.priority = SyncFieldPriority.normal,
  });

  /// The type of sync field
  final SyncFieldType type;

  /// Whether to compress this field's data before storage/transmission
  final bool compress;

  /// Whether to encrypt this field's data
  final bool encrypt;

  /// Priority for syncing this field
  final SyncFieldPriority priority;
}

/// Types of sync fields
enum SyncFieldType {
  /// A single file path
  file,

  /// A list of file paths
  fileList,

  /// JSON data that should be serialized specially
  json,

  /// Binary data (base64 encoded)
  binary,

  /// Location data (lat/lng)
  location,

  /// Custom type requiring special handling
  custom,
}

/// Priority levels for individual sync fields
enum SyncFieldPriority {
  low,
  normal,
  high,
}
