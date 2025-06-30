import 'package:equatable/equatable.dart';

/// Represents the result of a sync operation
class SyncResult extends Equatable {
  const SyncResult({
    required this.success,
    this.error,
    this.responseData,
    this.syncedAt,
  });

  /// Create a successful sync result
  factory SyncResult.success({
    Map<String, dynamic>? responseData,
  }) {
    return SyncResult(
      success: true,
      responseData: responseData,
      syncedAt: DateTime.now(),
    );
  }

  /// Create a failed sync result
  factory SyncResult.failure(String error) {
    return SyncResult(
      success: false,
      error: error,
      syncedAt: DateTime.now(),
    );
  }

  /// Whether the sync was successful
  final bool success;

  /// Error message if sync failed
  final String? error;

  /// Response data from the server
  final Map<String, dynamic>? responseData;

  /// When the sync was completed
  final DateTime? syncedAt;

  @override
  List<Object?> get props => [success, error, responseData, syncedAt];
}
