import 'package:flutter/material.dart';
import 'package:new_brand/resources/appNav.dart';
import 'package:new_brand/resources/socketServices.dart';

/// Wraps the app root so switching accounts on the same device — explicit
/// logout, forced session-expiry logout, or admin impersonation — can fully
/// tear down and recreate every provider in AppMultiProvider. Without this,
/// logout only ever cleared the token and swapped the navigator stack; every
/// ChangeNotifier created once at app start (categories, orders, dashboard
/// stats, chat threads, profile...) kept the previous seller's in-memory
/// data alive for whoever logged in next on the same device.
class RestartWidget extends StatefulWidget {
  final Widget child;
  const RestartWidget({super.key, required this.child});

  @override
  State<RestartWidget> createState() => RestartWidgetState();
}

class RestartWidgetState extends State<RestartWidget> {
  Key _key = UniqueKey();

  void restart() {
    setState(() => _key = UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _key, child: widget.child);
  }
}

final GlobalKey<RestartWidgetState> restartAppKey =
    GlobalKey<RestartWidgetState>();

// Set by restartApp(toLogin: true) right before the rebuild, read once by
// MyApp.build() in main.dart to pick LoginScreen over SplashScreen for the
// fresh Navigator's `home`. Logout already knows there's no token, so the
// splash's animation/delay/profile-fetch is pure dead time for that case.
bool _goStraightToLogin = false;

bool consumeGoStraightToLogin() {
  final value = _goStraightToLogin;
  _goStraightToLogin = false;
  return value;
}

/// Disposes every provider in the tree (new Key forces Flutter to unmount
/// the old subtree and mount a fresh one) and disconnects the chat socket
/// so the old account's auth/room subscription can't keep delivering
/// updates after the switch. Lands back on SplashScreen, which routes to
/// LoginScreen once it sees the token is gone (or straight to the dashboard
/// for impersonation, since the new token is already saved beforehand) —
/// unless [toLogin] is set (explicit/forced logout), which skips Splash
/// and goes directly to LoginScreen since the token is already known gone.
void restartApp({bool toLogin = false}) {
  SocketService().disconnect();
  // Fresh GlobalKey so the new MaterialApp's Navigator is genuinely
  // recreated (mounting `home: SplashScreen()`) instead of Flutter
  // reparenting the old Navigator — and its old route stack — onto it.
  appNavKey = GlobalKey<NavigatorState>();
  _goStraightToLogin = toLogin;
  restartAppKey.currentState?.restart();
}
