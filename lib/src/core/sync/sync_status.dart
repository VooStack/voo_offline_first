import 'package:equatable/equatable.dart';

/// Represents the current synchronization status
class SyncState extends Equatable {
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final int pendingChanges;
  final List<SyncError> errors;
  final double? progress;

  const SyncState({
    this.isSyncing = false,
    this.lastSyncTime,
    this.pendingChanges = 0,
    this.errors = const [],
    this.progress,
  });

  factory SyncState.idle() => const SyncState();

  factory SyncState.syncing({double? progress}) => SyncState(
        isSyncing: true,
        progress: progress,
      );

  SyncState copyWith({
    bool? isSyncing,
    DateTime? lastSyncTime,
    int? pendingChanges,
    List<SyncError>? errors,
    double? progress,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      errors: errors ?? this.errors,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [
        isSyncing,
        lastSyncTime,
        pendingChanges,
        errors,
        progress,
      ];
}

/// Represents a synchronization error
class SyncError extends Equatable {
  const SyncError({
    required this.entityId,
    required this.entityType,
    required this.message,
    required this.timestamp,
    required this.type,
  });
  final String entityId;
  final String entityType;
  final String message;
  final DateTime timestamp;
  final SyncErrorType type;

  @override
  List<Object> get props => [
        entityId,
        entityType,
        message,
        timestamp,
        type,
      ];
}

enum SyncErrorType {
  network,
  conflict,
  validation,
  server,
  unknown,
}
