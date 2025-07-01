import 'package:flutter/material.dart';
import '../../core/network/network_info.dart';

/// Widget that rebuilds based on network connectivity status
class OfflineBuilder extends StatelessWidget {
  final NetworkInfo networkInfo;
  final Widget Function(BuildContext context, bool isOnline) builder;
  final Widget? child;

  const OfflineBuilder({
    super.key,
    required this.networkInfo,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: networkInfo.connectivityStream,
      initialData: true, // Assume online initially
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? false;

        if (child != null) {
          return Stack(
            children: [
              child!,
              if (!isOnline) _buildOfflineIndicator(context),
            ],
          );
        }

        return builder(context, isOnline);
      },
    );
  }

  Widget _buildOfflineIndicator(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        child: Container(
          color: Colors.red,
          padding: const EdgeInsets.all(8.0),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text(
                'No internet connection',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple offline indicator widget
class OfflineIndicator extends StatelessWidget {
  final NetworkInfo networkInfo;
  final Widget? onlineChild;
  final Widget? offlineChild;

  const OfflineIndicator({
    super.key,
    required this.networkInfo,
    this.onlineChild,
    this.offlineChild,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: networkInfo.connectivityStream,
      initialData: true,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? false;

        if (isOnline) {
          return onlineChild ?? const SizedBox.shrink();
        }

        return offlineChild ??
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Offline',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
      },
    );
  }
}
