/// Sync progress model (from sync_manager interface)
class SyncProgress {
  const SyncProgress({
    required this.total,
    required this.completed,
    required this.failed,
    required this.inProgress,
  });

  final int total;
  final int completed;
  final int failed;
  final int inProgress;

  int get pending => total - completed - failed - inProgress;
  double get completionPercentage => total > 0 ? completed / total : 0.0;
}
