import 'package:flutter/material.dart';
import 'package:new_brand/view/companySide/auth/loginScreen.dart';
import 'package:new_brand/resources/local_storage.dart';

final GlobalKey<NavigatorState> appNavKey = GlobalKey<NavigatorState>();

class AppNav {
  static bool _busy = false;

  static Future<void> forceLogoutToLogin() async {
    if (_busy) return;
    _busy = true;

    await LocalStorage.clearToken();

    final nav = appNavKey.currentState;
    if (nav != null) {
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }

    _busy = false;
  }
}
