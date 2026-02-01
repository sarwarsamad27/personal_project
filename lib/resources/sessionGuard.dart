import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/network/network_api_services.dart';

class SessionGuard extends StatefulWidget {
  final Widget child;
  const SessionGuard({super.key, required this.child});

  @override
  State<SessionGuard> createState() => _SessionGuardState();
}

class _SessionGuardState extends State<SessionGuard> {
  Timer? _timer;

  String _normalizeToken(String token) {
    final t = token.trim();
    if (t.toLowerCase().startsWith('bearer ')) {
      return t.substring(7).trim();
    }
    return t;
  }

  bool _isTokenExpiredSafe(String token) {
    try {
      final t = _normalizeToken(token);
      final decoded = JwtDecoder.decode(t);
      if (!decoded.containsKey('exp') || decoded['exp'] == null) return true;
      return JwtDecoder.isExpired(t);
    } catch (_) {
      return true;
    }
  }

  @override
  void initState() {
    super.initState();
    _check();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _check());
  }

  Future<void> _check() async {
    final tokenRaw = await LocalStorage.getToken();
    if (tokenRaw == null || tokenRaw.trim().isEmpty) return;

    final expired = _isTokenExpiredSafe(tokenRaw);
    if (expired) {
      await NetworkApiServices.forceLogoutGlobal();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
