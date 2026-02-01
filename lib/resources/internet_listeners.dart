import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:new_brand/resources/toast.dart';

class InternetListener {
  InternetListener._();

  // ✅ NEW: stream now emits List<ConnectivityResult>
  static StreamSubscription<List<ConnectivityResult>>? _sub;

  static bool _isOffline = false;
  static DateTime _lastToastAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// ✅ call once from main()
  static Future<void> start() async {
    if (_sub != null) return;

    // initial check
    final initOk = await _hasInternet();
    _isOffline = !initOk;

    _sub = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      // results can contain multiple (wifi + vpn etc), but our real check is DNS
      final ok = await _hasInternet();

      if (!ok && !_isOffline) {
        _isOffline = true;
        _showOncePerFewSeconds("Your internet disconnected");
      } else if (ok && _isOffline) {
        _isOffline = false;
        _showOncePerFewSeconds("Back online");
      }
    });
  }

  static Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  static void _showOncePerFewSeconds(String msg) {
    final now = DateTime.now();
    if (now.difference(_lastToastAt).inSeconds < 2) return;
    _lastToastAt = now;

    try {
      // aapka existing toast
      AppToast.error(msg);
    } catch (e) {
      if (kDebugMode) print("Toast error: $e");
    }
  }

  /// true internet check (not only wifi/mobile)
  static Future<bool> _hasInternet() async {
    // ✅ NEW: checkConnectivity also returns List now (latest versions)
    final results = await Connectivity().checkConnectivity();

    // if list empty OR contains none => no connectivity
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return false;
    }

    try {
      final result = await InternetAddress.lookup("google.com");
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
