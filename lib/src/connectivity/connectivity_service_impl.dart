import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/interfaces/connectivity_service.dart';

/// Implementation of ConnectivityService using connectivity_plus
class ConnectivityServiceImpl implements ConnectivityService {
  ConnectivityServiceImpl({
    this.testHost = 'google.com',
    this.testPort = 80,
    this.testTimeout = const Duration(seconds: 5),
  });

  final Connectivity _connectivity = Connectivity();
  final String testHost;
  final int testPort;
  final Duration testTimeout;

  StreamController<bool>? _connectivityController;
  StreamController<ConnectionType>? _connectionTypeController;
  StreamController<ConnectionQuality>? _qualityController;

  StreamSubscription? _connectivitySubscription;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    _connectivityController = StreamController<bool>.broadcast();
    _connectionTypeController = StreamController<ConnectionType>.broadcast();
    _qualityController = StreamController<ConnectionQuality>.broadcast();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        final connectionType = _mapConnectivityResult([result]);
        final isConnected = connectionType != ConnectionType.none;

        _connectionTypeController?.add(connectionType);

        if (isConnected) {
          // Test actual internet connectivity
          final actuallyConnected = await canReachHost(testHost);
          _connectivityController?.add(actuallyConnected);

          if (actuallyConnected) {
            final quality = await getConnectionQuality();
            _qualityController?.add(quality);
          } else {
            _qualityController?.add(ConnectionQuality.none);
          }
        } else {
          _connectivityController?.add(false);
          _qualityController?.add(ConnectionQuality.none);
        }
      },
    );

    _isInitialized = true;
  }

  @override
  Future<bool> isConnected() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    if (_mapConnectivityResult(connectivityResults as List<ConnectivityResult>) == ConnectionType.none) {
      return false;
    }

    // Test actual internet connectivity
    return await canReachHost(testHost);
  }

  @override
  Future<ConnectionType> getConnectionType() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    return _mapConnectivityResult(connectivityResults as List<ConnectivityResult>);
  }

  @override
  Future<bool> canReachHost(String host) async {
    try {
      final socket = await Socket.connect(host, testPort, timeout: testTimeout);
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<bool> watchConnectivity() {
    if (_connectivityController == null) {
      throw StateError('ConnectivityService not initialized. Call initialize() first.');
    }
    return _connectivityController!.stream;
  }

  @override
  Stream<ConnectionType> watchConnectionType() {
    if (_connectionTypeController == null) {
      throw StateError('ConnectivityService not initialized. Call initialize() first.');
    }
    return _connectionTypeController!.stream;
  }

  @override
  Future<ConnectionQuality> getConnectionQuality() async {
    if (!await isConnected()) {
      return ConnectionQuality.none;
    }

    try {
      // Simple ping test to measure latency
      final stopwatch = Stopwatch()..start();
      final socket = await Socket.connect(testHost, testPort, timeout: testTimeout);
      stopwatch.stop();
      socket.destroy();

      final latency = stopwatch.elapsed;

      // Classify connection quality based on latency
      if (latency.inMilliseconds < 50) {
        return ConnectionQuality.excellent;
      } else if (latency.inMilliseconds < 150) {
        return ConnectionQuality.good;
      } else if (latency.inMilliseconds < 300) {
        return ConnectionQuality.moderate;
      } else {
        return ConnectionQuality.poor;
      }
    } catch (e) {
      return ConnectionQuality.poor;
    }
  }

  @override
  Stream<ConnectionQuality> watchConnectionQuality() {
    if (_qualityController == null) {
      throw StateError('ConnectivityService not initialized. Call initialize() first.');
    }
    return _qualityController!.stream;
  }

  @override
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _connectivityController?.close();
    await _connectionTypeController?.close();
    await _qualityController?.close();

    _connectivityController = null;
    _connectionTypeController = null;
    _qualityController = null;
    _isInitialized = false;
  }

  /// Map connectivity_plus results to our ConnectionType enum
  ConnectionType _mapConnectivityResult(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      return ConnectionType.none;
    }

    // Prioritize connection types
    if (results.contains(ConnectivityResult.wifi)) {
      return ConnectionType.wifi;
    } else if (results.contains(ConnectivityResult.mobile)) {
      return ConnectionType.mobile;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return ConnectionType.ethernet;
    } else if (results.contains(ConnectivityResult.bluetooth)) {
      return ConnectionType.bluetooth;
    } else if (results.contains(ConnectivityResult.other)) {
      return ConnectionType.other;
    } else {
      return ConnectionType.none;
    }
  }
}
