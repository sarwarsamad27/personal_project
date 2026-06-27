import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appNav.dart';
import 'package:new_brand/resources/restartWidget.dart';
import 'package:new_brand/resources/sessionGuard.dart';
import 'package:new_brand/view/companySide/auth/splashScreen.dart';
import 'package:new_brand/viewModel/providers/connectivity_provider.dart';
import 'package:new_brand/viewModel/providers/syncCoordinator_provider.dart';
import 'package:new_brand/resources/appTheme.dart';
import 'package:new_brand/viewModel/multiProvider/multiProvider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// ✅ ADD

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _highChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'Used for general notifications',
  importance: Importance.high,
);

const AndroidNotificationChannel _orderChannel = AndroidNotificationChannel(
  'new_order_alert_channel',
  'New Order Alerts',
  description: 'Used for new order notifications',
  importance: Importance.max,
);

Future<void> _initLocalNotifications() async {
  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('ic_notification');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInit,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (_) {},
  );

  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  await androidPlugin?.createNotificationChannel(_highChannel);
  await androidPlugin?.createNotificationChannel(_orderChannel);
}

Future<void> _setupFirebaseForegroundHandler() async {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final isOrder = message.data['type'] == 'NEW_ORDER';
    final ch = isOrder ? _orderChannel : _highChannel;

    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          ch.id,
          ch.name,
          channelDescription: ch.description,
          importance: ch.importance,
          priority: Priority.high,
          icon: 'ic_notification',
          color: const Color(0xFFDB9F3A),
        ),
      ),
    );
  });
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (!e.toString().contains('duplicate-app')) rethrow;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (!e.toString().contains('duplicate-app')) rethrow;
  }
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await _initLocalNotifications();
  await _setupFirebaseForegroundHandler();

  // ✅ start internet listener ONCE
  // await InternetListener.start();

  runApp(RestartWidget(key: restartAppKey, child: const AppWrapper()));
}

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return AppMultiProvider(
      child: _OfflineSyncRegistrar(child: const MyApp()),
    );
  }
}

class _OfflineSyncRegistrar extends StatefulWidget {
  final Widget child;
  const _OfflineSyncRegistrar({required this.child});
  @override
  State<_OfflineSyncRegistrar> createState() => _OfflineSyncRegistrarState();
}

class _OfflineSyncRegistrarState extends State<_OfflineSyncRegistrar> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final connectivity = context.read<ConnectivityProvider>();
      connectivity.addReconnectCallback(
        context.read<SyncCoordinator>().syncAll,
      );
    });
    _initDeepLinks();
  }

  // Admin "Account Visit" deep link: shookooseller://impersonate?token=...
  Future<void> _initDeepLinks() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) _handleLink(initial);
    } catch (_) {}

    _linkSub = _appLinks.uriLinkStream.listen(_handleLink, onError: (_) {});
  }

  void _handleLink(Uri uri) {
    if (uri.scheme != 'shookooseller' || uri.host != 'impersonate') return;
    final token = uri.queryParameters['token'];
    if (token == null || token.isEmpty) return;
    AppNav.startImpersonation(token);
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Consumer<ConnectivityProvider>(
          builder: (context, connectivity, child) {
            return MaterialApp(
              navigatorKey: appNavKey,
              debugShowCheckedModeBanner: false,
              title: 'SHOOKOO',
              theme: AppTheme.lightTheme,
              home: SessionGuard(child: SplashScreen()),
              builder: (context, child) => Column(
                children: [
                  if (!connectivity.isConnected)
                    Material(
                      child: SafeArea(
                        bottom: false,
                        child: Container(
                          width: double.infinity,
                          color: const Color(0xFFE65100),
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 16),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.wifi_off,
                                  color: Colors.white, size: 14),
                              SizedBox(width: 6),
                              Text(
                                'No internet — cached data',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Expanded(child: child!),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
