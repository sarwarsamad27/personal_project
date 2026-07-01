import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appNav.dart';
import 'package:new_brand/resources/restartWidget.dart';
import 'package:new_brand/resources/sessionGuard.dart';
import 'package:new_brand/view/companySide/auth/loginScreen.dart';
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

// Downloads the notification's image (e.g. the ordered product's photo) so
// it can be shown as a large icon + expandable big picture — Android's
// notification API needs the actual bytes, not just a remote URL.
Future<ByteArrayAndroidBitmap?> _downloadNotificationImage(String url) async {
  try {
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 6));
    if (response.statusCode == 200) {
      return ByteArrayAndroidBitmap(response.bodyBytes);
    }
  } catch (_) {}
  return null;
}

Future<void> _setupFirebaseForegroundHandler() async {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final isOrder = message.data['type'] == 'NEW_ORDER';
    final ch = isOrder ? _orderChannel : _highChannel;

    final imageUrl = message.data['image'];
    final imageBitmap = (imageUrl != null && imageUrl.isNotEmpty)
        ? await _downloadNotificationImage(imageUrl)
        : null;

    await flutterLocalNotificationsPlugin.show(
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
          largeIcon: imageBitmap,
          styleInformation: imageBitmap != null
              ? BigPictureStyleInformation(
                  imageBitmap,
                  largeIcon: imageBitmap,
                  contentTitle: notification.title,
                  summaryText: notification.body,
                )
              : null,
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
  await dotenv.load(fileName: ".env");
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
    return AppMultiProvider(child: _OfflineSyncRegistrar(child: const MyApp()));
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Read exactly once per mount. Consumer<ConnectivityProvider> below
  // rebuilds shortly after launch (ConnectivityProvider's constructor does
  // an async connectivity + internet probe before its first notifyListeners()),
  // which used to re-evaluate consumeGoStraightToLogin() — a one-shot flag —
  // a second time. The second read always came back false (already
  // consumed), flipping `home` from LoginScreen back to SplashScreen right
  // after a logout, so the splash screen would flash before redirecting
  // back to login.
  late final bool _goStraightToLogin = consumeGoStraightToLogin();

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
              home: SessionGuard(
                child: _goStraightToLogin
                    ? const LoginScreen()
                    : SplashScreen(),
              ),
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
                            vertical: 6,
                            horizontal: 16,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wifi_off,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'No internet — cached data',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
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
