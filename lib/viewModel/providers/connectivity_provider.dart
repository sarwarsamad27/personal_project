import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  /// Static accessor — use in non-widget code (e.g. NetworkApiServices).
  static bool _staticOnline = true;
  static bool get online => _staticOnline;

  final List<VoidCallback> _reconnectCallbacks = [];

  void addReconnectCallback(VoidCallback cb) {
    if (!_reconnectCallbacks.contains(cb)) _reconnectCallbacks.add(cb);
  }

  void removeReconnectCallback(VoidCallback cb) =>
      _reconnectCallbacks.remove(cb);

  late StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityProvider() {
    _init();
  }

  void _init() async {
    _isConnected = await _checkRealInternet();
    _staticOnline = _isConnected;
    notifyListeners();

    _subscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) async {
      await _updateStatus(results);
    });
  }

  Future<void> _updateStatus(List<ConnectivityResult> results) async {
    final wasConnected = _isConnected;
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      _isConnected = false;
    } else {
      _isConnected = await _checkRealInternet();
    }
    _staticOnline = _isConnected;

    if (!wasConnected && _isConnected) {
      for (final cb in [..._reconnectCallbacks]) {
        try {
          cb();
        } catch (_) {}
      }
    }

    notifyListeners();
  }

  Future<bool> _checkRealInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
