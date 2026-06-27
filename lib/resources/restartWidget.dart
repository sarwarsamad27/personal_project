import 'package:flutter/material.dart';
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

/// Disposes every provider in the tree (new Key forces Flutter to unmount
/// the old subtree and mount a fresh one) and disconnects the chat socket
/// so the old account's auth/room subscription can't keep delivering
/// updates after the switch. Lands back on SplashScreen, which routes to
/// LoginScreen once it sees the token is gone (or straight to the dashboard
/// for impersonation, since the new token is already saved beforehand).
/// Call right after saving/clearing the token on any account switch.
void restartApp() {
  SocketService().disconnect();
  restartAppKey.currentState?.restart();
}
