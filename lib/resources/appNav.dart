import 'package:flutter/material.dart';
import 'package:new_brand/view/companySide/auth/loginScreen.dart';
import 'package:new_brand/view/companySide/auth/splashScreen.dart';
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

  // Admin "Account Visit" deep link lands here with an impersonation token.
  // Saves it exactly like a normal login would, then restarts at the splash
  // screen so its existing token-check + profile-fetch logic takes over and
  // routes to the dashboard — no separate routing logic to keep in sync.
  static Future<void> startImpersonation(String token) async {
    await LocalStorage.saveToken(token);

    final nav = appNavKey.currentState;
    if (nav != null) {
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => SplashScreen()),
        (route) => false,
      );
    }
  }
}
