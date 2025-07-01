import 'package:flutter/material.dart';
import '../../core/sync/sync_manager.dart';
import '../../core/sync/sync_status.dart';

/// Widget that displays the current sync status
class SyncIndicator extends StatelessWidget {
  final SyncManager syncManager;
  final Widget Function(BuildContext context, SyncState state)? builder;
  final bool showErrors;
  final bool showProgress;

  const SyncIndicator({
    super.key,
    required this.syncManager,
    this.builder,
    this.showErrors = true,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncState>(
      stream: syncManager.syncStateStream,
      initialData: syncManager.currentState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const SyncState();

        if (builder != null) {
          return builder!(context, state);
        }

        return _buildDefaultIndicator(context, state);
      },
    );
  }

  Widget _buildDefaultIndicator(BuildContext context, SyncState state) {
    if (state.isSyncing) {
      return _buildSyncingIndicator(context, state);
    }

    if (state.errors.isNotEmpty && showErrors) {
      return _buildErrorIndicator(context, state);
    }

    if (state.pendingChanges > 0) {
      return _buildPendingIndicator(context, state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildSyncingIndicator(BuildContext context, SyncState state) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(width: 8),
          const Text('Syncing...'),
          if (showProgress && state.progress != null) ...[
            const SizedBox(width: 8),
            Text('${(state.progress! * 100).toInt()}%'),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorIndicator(BuildContext context, SyncState state) {
    return GestureDetector(
      onTap: () => _showErrorDetails(context, state.errors),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 16),
            const SizedBox(width: 8),
            Text(
              '${state.errors.length} sync error${state.errors.length > 1 ? 's' : ''}',
              style: const TextStyle(color: Colors.red),
            ),
            const Icon(Icons.chevron_right, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingIndicator(BuildContext context, SyncState state) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_upload, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          Text(
            '${state.pendingChanges} pending',
            style: const TextStyle(color: Colors.orange),
          ),
        ],
      ),
    );
  }

  void _showErrorDetails(BuildContext context, List<SyncError> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Errors'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: errors
                .map((error) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            error.entityType,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(error.message),
                          Text(
                            _formatTime(error.timestamp),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              syncManager.retryFailedSyncs();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

/// Minimal sync status icon
class SyncStatusIcon extends StatelessWidget {
  final SyncManager syncManager;
  final double size;

  const SyncStatusIcon({
    super.key,
    required this.syncManager,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncState>(
      stream: syncManager.syncStateStream,
      initialData: syncManager.currentState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const SyncState();

        if (state.isSyncing) {
          return SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          );
        }

        if (state.errors.isNotEmpty) {
          return Icon(
            Icons.sync_problem,
            size: size,
            color: Colors.red,
          );
        }

        if (state.pendingChanges > 0) {
          return Icon(
            Icons.sync,
            size: size,
            color: Colors.orange,
          );
        }

        return Icon(
          Icons.check_circle,
          size: size,
          color: Colors.green,
        );
      },
    );
  }
}
