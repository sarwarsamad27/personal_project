import 'package:flutter/material.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/restartWidget.dart';

final GlobalKey<NavigatorState> appNavKey = GlobalKey<NavigatorState>();

class AppNav {
  static bool _busy = false;

  static Future<void> forceLogoutToLogin() async {
    if (_busy) return;
    _busy = true;

    await LocalStorage.clearToken();

    // Full provider-tree restart (not just a nav push) — otherwise the
    // previous seller's in-memory data (categories, orders, dashboard,
    // chat...) stays cached for whoever logs in next on this device.
    restartApp();

    _busy = false;
  }

  // Admin "Account Visit" deep link lands here with an impersonation token.
  // Saves it exactly like a normal login would, then restarts the whole
  // provider tree (not just a nav push) so no in-memory data from whichever
  // account was previously active on this device leaks into the
  // impersonated session — then SplashScreen's existing token-check +
  // profile-fetch logic takes over and routes to the dashboard.
  static Future<void> startImpersonation(String token) async {
    await LocalStorage.saveToken(token);
    restartApp();
  }
}
