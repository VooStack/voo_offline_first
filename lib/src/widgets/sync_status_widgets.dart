import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voo_offline_first/src/core/models/sync_progress.dart';
import 'package:voo_offline_first/voo_offline_first.dart';
import '../bloc/sync_bloc.dart';
import '../bloc/sync_event.dart';
import '../bloc/sync_state.dart';
import '../core/models/upload_status.dart';

/// Widget that displays the overall sync status
class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({
    super.key,
    this.showText = true,
    this.size = 24.0,
  });

  final bool showText;
  final double size;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(state),
            if (showText) ...[
              const SizedBox(width: 8),
              Text(
                _getStatusText(state),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStatusIcon(SyncState state) {
    if (state is SyncInProgress) {
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          value: state.progress.completionPercentage,
        ),
      );
    }

    IconData icon;
    Color color;

    if (state is SyncIdle) {
      if (state.isConnected) {
        icon = Icons.cloud_done;
        color = Colors.green;
      } else {
        icon = Icons.cloud_off;
        color = Colors.orange;
      }
    } else if (state is SyncPaused) {
      icon = Icons.pause_circle;
      color = Colors.orange;
    } else if (state is SyncError) {
      icon = Icons.error;
      color = Colors.red;
    } else if (state is SyncSuccess) {
      icon = Icons.check_circle;
      color = Colors.green;
    } else {
      icon = Icons.sync;
      color = Colors.grey;
    }

    return Icon(icon, size: size, color: color);
  }

  String _getStatusText(SyncState state) {
    if (state is SyncInProgress) {
      final progress = state.progress;
      return 'Syncing ${progress.completed}/${progress.total}';
    } else if (state is SyncIdle) {
      if (state.isConnected) {
        final pending = state.progress.pending;
        return pending > 0 ? '$pending pending' : 'All synced';
      } else {
        return 'Offline';
      }
    } else if (state is SyncPaused) {
      return 'Paused';
    } else if (state is SyncError) {
      return 'Sync error';
    } else if (state is SyncSuccess) {
      return 'Sync complete';
    } else {
      return 'Initializing';
    }
  }
}

/// Widget that shows detailed sync progress
class SyncProgressCard extends StatelessWidget {
  const SyncProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        final progress = _getProgress(state);
        final isConnected = _getConnectionStatus(state);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isConnected ? Icons.wifi : Icons.wifi_off,
                      color: isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isConnected ? 'Connected' : 'Offline',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    _buildSyncActions(context, state),
                  ],
                ),
                const SizedBox(height: 16),
                if (progress.total > 0) ...[
                  LinearProgressIndicator(
                    value: progress.completionPercentage,
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${progress.completed}/${progress.total} completed'),
                      Text('${(progress.completionPercentage * 100).round()}%'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildProgressChip('Pending', progress.pending, Colors.blue),
                      const SizedBox(width: 8),
                      _buildProgressChip('In Progress', progress.inProgress, Colors.orange),
                      const SizedBox(width: 8),
                      _buildProgressChip('Failed', progress.failed, Colors.red),
                    ],
                  ),
                ] else ...[
                  const Text('No items to sync'),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSyncActions(BuildContext context, SyncState state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state is SyncIdle || state is SyncPaused)
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              context.read<SyncBloc>().add(const SyncTriggerSync());
            },
            tooltip: 'Sync now',
          ),
        if (state is SyncInProgress)
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: () {
              context.read<SyncBloc>().add(const SyncStopAutoSync());
            },
            tooltip: 'Pause sync',
          ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'retry_failed':
                context.read<SyncBloc>().add(const SyncRetryFailed());
                break;
              case 'clear_completed':
                context.read<SyncBloc>().add(const SyncClearCompleted());
                break;
              case 'toggle_auto_sync':
                if (state is SyncIdle && state.autoSyncEnabled) {
                  context.read<SyncBloc>().add(const SyncStopAutoSync());
                } else {
                  context.read<SyncBloc>().add(const SyncStartAutoSync());
                }
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'retry_failed',
              child: Text('Retry failed items'),
            ),
            const PopupMenuItem(
              value: 'clear_completed',
              child: Text('Clear completed'),
            ),
            PopupMenuItem(
              value: 'toggle_auto_sync',
              child: Text(
                state is SyncIdle && state.autoSyncEnabled ? 'Disable auto-sync' : 'Enable auto-sync',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressChip(String label, int count, Color color) {
    return Chip(
      label: Text('$label: $count'),
      backgroundColor: color.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: color),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  SyncProgress _getProgress(SyncState state) {
    if (state is SyncIdle) return state.progress;
    if (state is SyncInProgress) return state.progress;
    if (state is SyncPaused) return state.progress;
    if (state is SyncError) return state.progress;
    if (state is SyncSuccess) return state.progress;
    return const SyncProgress(total: 0, completed: 0, failed: 0, inProgress: 0);
  }

  bool _getConnectionStatus(SyncState state) {
    if (state is SyncIdle) return state.isConnected;
    if (state is SyncInProgress) return state.isConnected;
    if (state is SyncPaused) return state.isConnected;
    if (state is SyncError) return state.isConnected;
    if (state is SyncSuccess) return state.isConnected;
    return false;
  }
}

/// Widget that displays sync status for individual items
class ItemSyncStatus extends StatelessWidget {
  const ItemSyncStatus({
    super.key,
    required this.status,
    this.compact = false,
  });

  final UploadStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactStatus();
    } else {
      return _buildDetailedStatus(context);
    }
  }

  Widget _buildCompactStatus() {
    IconData icon;
    Color color;

    switch (status.state) {
      case UploadState.pending:
        icon = Icons.schedule;
        color = Colors.orange;
        break;
      case UploadState.uploading:
        icon = Icons.cloud_upload;
        color = Colors.blue;
        break;
      case UploadState.completed:
        icon = Icons.cloud_done;
        color = Colors.green;
        break;
      case UploadState.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
      case UploadState.cancelled:
        icon = Icons.cancel;
        color = Colors.grey;
        break;
    }

    return Icon(icon, color: color, size: 16);
  }

  Widget _buildDetailedStatus(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildCompactStatus(),
            const SizedBox(width: 8),
            Text(
              _getStatusText(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        if (status.isUploading) ...[
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: status.progress,
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(height: 4),
          Text(
            '${(status.progress * 100).round()}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (status.isFailed && status.error != null) ...[
          const SizedBox(height: 4),
          Text(
            status.error!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.red,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  String _getStatusText() {
    switch (status.state) {
      case UploadState.pending:
        return 'Pending upload';
      case UploadState.uploading:
        return 'Uploading...';
      case UploadState.completed:
        return 'Uploaded';
      case UploadState.failed:
        return 'Upload failed';
      case UploadState.cancelled:
        return 'Cancelled';
    }
  }
}

/// A floating action button that shows sync status and allows manual sync
class SyncFab extends StatelessWidget {
  const SyncFab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        return FloatingActionButton(
          onPressed: () {
            if (state is SyncIdle || state is SyncPaused) {
              context.read<SyncBloc>().add(const SyncTriggerSync());
            }
          },
          backgroundColor: _getFabColor(state),
          child: _buildFabIcon(state),
        );
      },
    );
  }

  Widget _buildFabIcon(SyncState state) {
    if (state is SyncInProgress) {
      return Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: state.progress.completionPercentage,
            strokeWidth: 2.0,
            color: Colors.white,
          ),
          const Icon(Icons.sync, size: 20),
        ],
      );
    } else if (state is SyncError) {
      return const Icon(Icons.sync_problem);
    } else if (state is SyncSuccess) {
      return const Icon(Icons.check);
    } else {
      return const Icon(Icons.sync);
    }
  }

  Color _getFabColor(SyncState state) {
    if (state is SyncInProgress) {
      return Colors.blue;
    } else if (state is SyncError) {
      return Colors.red;
    } else if (state is SyncSuccess) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }
}

/// A banner that shows when the app is offline
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        final isConnected = _getConnectionStatus(state);

        if (isConnected) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          color: Colors.orange,
          child: Row(
            children: [
              const Icon(Icons.wifi_off, color: Colors.white),
              const SizedBox(width: 8),
              const Text(
                'You are offline. Changes will sync when connection is restored.',
                style: TextStyle(color: Colors.white),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  context.read<SyncBloc>().add(const SyncTriggerSync());
                },
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _getConnectionStatus(SyncState state) {
    if (state is SyncIdle) return state.isConnected;
    if (state is SyncInProgress) return state.isConnected;
    if (state is SyncPaused) return state.isConnected;
    if (state is SyncError) return state.isConnected;
    if (state is SyncSuccess) return state.isConnected;
    return false;
  }
}
