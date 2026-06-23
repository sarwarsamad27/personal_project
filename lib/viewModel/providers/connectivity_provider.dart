import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  /// Static accessor — use in non-widget code (e.g. NetworkApiServices).
  /// True only when a real internet probe (google.com) succeeds.
  static bool _staticOnline = true;
  static bool get online => _staticOnline;

  /// True whenever the OS reports ANY network interface (WiFi/mobile/
  /// ethernet), regardless of whether the stricter internet probe succeeds.
  /// Use this to decide whether to attempt a real API call — a local/dev
  /// backend (e.g. 10.0.2.2) can be perfectly reachable even when the
  /// google.com probe fails (flaky emulator DNS, restrictive networks).
  static bool _staticHasInterface = true;
  static bool get hasNetworkInterface => _staticHasInterface;

  /// Sequential, awaited reconnect callbacks — fired in registration order,
  /// one fully completing before the next starts. Avoids races where a
  /// screen refresh runs before the queue sync it depends on has finished.
  final List<Future<void> Function()> _reconnectCallbacks = [];

  void addReconnectCallback(Future<void> Function() cb) {
    if (!_reconnectCallbacks.contains(cb)) _reconnectCallbacks.add(cb);
  }

  void removeReconnectCallback(Future<void> Function() cb) =>
      _reconnectCallbacks.remove(cb);

  late StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityProvider() {
    _init();
  }

  void _init() async {
    final results = await Connectivity().checkConnectivity();
    _staticHasInterface = _hasInterface(results);
    _isConnected = _staticHasInterface ? await _checkRealInternet() : false;
    _staticOnline = _isConnected;
    notifyListeners();

    _subscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) async {
      await _updateStatus(results);
    });
  }

  bool _hasInterface(List<ConnectivityResult> results) =>
      results.isNotEmpty && !results.contains(ConnectivityResult.none);

  Future<void> _updateStatus(List<ConnectivityResult> results) async {
    final wasHasInterface = _staticHasInterface;
    _staticHasInterface = _hasInterface(results);
    _isConnected = _staticHasInterface ? await _checkRealInternet() : false;
    _staticOnline = _isConnected;

    // Trigger sync on interface reappearing (not the stricter internet
    // probe) — a local/dev backend works the moment WiFi/data comes back,
    // even if google.com itself is unreachable.
    if (!wasHasInterface && _staticHasInterface) {
      for (final cb in [..._reconnectCallbacks]) {
        try {
          await cb();
        } catch (_) {}
      }
    }

    notifyListeners();
  }

  Future<bool> _checkRealInternet() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
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
