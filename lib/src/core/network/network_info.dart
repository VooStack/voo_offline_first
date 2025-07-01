import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get connectivityStream;
}

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl({required this.connectivity}) {
    _initializeConnectivityStream();
  }
  final Connectivity connectivity;
  final _connectivityController = StreamController<bool>.broadcast();

  void _initializeConnectivityStream() {
    connectivity.onConnectivityChanged.listen((result) {
      _connectivityController.add(_isConnected(result));
    });
  }

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return _isConnected(result);
  }

  @override
  Stream<bool> get connectivityStream => _connectivityController.stream;

  bool _isConnected(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  void dispose() {
    _connectivityController.close();
  }
}
