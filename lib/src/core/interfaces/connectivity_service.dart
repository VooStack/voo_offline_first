/// Abstract interface for connectivity management
///
/// This service monitors network connectivity and provides information
/// about the current connection status.
abstract class ConnectivityService {
  /// Initialize the connectivity service
  Future<void> initialize();

  /// Check if currently connected to the internet
  Future<bool> isConnected();

  /// Get the current connection type
  Future<ConnectionType> getConnectionType();

  /// Test if a specific host is reachable
  Future<bool> canReachHost(String host);

  /// Watch connectivity status for real-time updates
  Stream<bool> watchConnectivity();

  /// Watch connection type changes
  Stream<ConnectionType> watchConnectionType();

  /// Get connection quality information
  Future<ConnectionQuality> getConnectionQuality();

  /// Watch connection quality changes
  Stream<ConnectionQuality> watchConnectionQuality();

  /// Dispose of resources
  Future<void> dispose();
}

/// Types of network connections
enum ConnectionType {
  none,
  wifi,
  mobile,
  ethernet,
  bluetooth,
  other,
}

/// Connection quality levels
enum ConnectionQuality {
  /// No connection
  none,

  /// Very poor connection (high latency, low bandwidth)
  poor,

  /// Moderate connection (medium latency and bandwidth)
  moderate,

  /// Good connection (low latency, high bandwidth)
  good,

  /// Excellent connection (very low latency, very high bandwidth)
  excellent,
}

/// Connection information
class ConnectionInfo {
  const ConnectionInfo({
    required this.isConnected,
    required this.type,
    required this.quality,
    this.signalStrength,
    this.bandwidth,
    this.latency,
  });

  final bool isConnected;
  final ConnectionType type;
  final ConnectionQuality quality;
  final double? signalStrength; // 0.0 to 1.0
  final double? bandwidth; // in Mbps
  final Duration? latency;
}
