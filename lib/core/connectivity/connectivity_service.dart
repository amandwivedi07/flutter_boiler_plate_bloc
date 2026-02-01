import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Network connectivity status. Use to show offline UI or disable API calls.
abstract class ConnectivityService {
  Stream<bool> get isConnectedStream;
  Future<bool> get isConnected;
  Future<void> checkConnection();
}

class ConnectivityServiceImpl implements ConnectivityService {
  ConnectivityServiceImpl(this._connectivity);

  final Connectivity _connectivity;

  @override
  Stream<bool> get isConnectedStream => _connectivity.onConnectivityChanged
      .map((results) => !_isNone(results));

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return !_isNone(results);
  }

  @override
  Future<void> checkConnection() async {
    await _connectivity.checkConnectivity();
  }

  bool _isNone(List<ConnectivityResult> results) {
    if (results.isEmpty) return true;
    return results.length == 1 && results.single == ConnectivityResult.none;
  }
}
