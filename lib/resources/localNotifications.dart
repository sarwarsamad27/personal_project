import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Single shared plugin instance — imported by both `main.dart` (FCM-driven
/// push notifications) and anything that needs to fire a purely local
/// notification (e.g. background upload completion) without going through
/// the server. Kept in its own file (rather than declared in main.dart) so
/// non-UI code (providers) can show a notification without importing
/// main.dart.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel highImportanceChannel =
    AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for general notifications',
      importance: Importance.high,
    );

const AndroidNotificationChannel newOrderAlertChannel =
    AndroidNotificationChannel(
      'new_order_alert_channel',
      'New Order Alerts',
      description: 'Used for new order notifications',
      importance: Importance.max,
    );

Future<void> initLocalNotifications() async {
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

  await androidPlugin?.createNotificationChannel(highImportanceChannel);
  await androidPlugin?.createNotificationChannel(newOrderAlertChannel);
}
