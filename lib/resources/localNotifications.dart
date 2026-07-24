import 'package:flutter/material.dart';
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

// Locally-triggered only (never via FCM) — fired when a background
// image/video upload (add product, edit product, review reply...) finishes.
// Deliberately lower importance than order alerts: it's a convenience ping,
// not something that needs to interrupt the user.
const AndroidNotificationChannel uploadStatusChannel =
    AndroidNotificationChannel(
      'upload_status_channel',
      'Upload Status',
      description: 'Notifies when a background image/video upload finishes',
      importance: Importance.defaultImportance,
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
  await androidPlugin?.createNotificationChannel(uploadStatusChannel);
}

/// Fires a plain "done" notification — title/body only, deliberately no
/// progress percentage (that belongs on the in-app overlay, not here).
Future<void> showUploadStatusNotification({
  required String title,
  required String body,
}) async {
  await flutterLocalNotificationsPlugin.show(
    // Negative id range keeps these out of the way of FCM notification ids
    // (which use RemoteMessage.notification.hashCode).
    -DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        uploadStatusChannel.id,
        uploadStatusChannel.name,
        channelDescription: uploadStatusChannel.description,
        importance: uploadStatusChannel.importance,
        priority: Priority.defaultPriority,
        icon: 'ic_notification',
        color: const Color(0xFFDB9F3A),
      ),
    ),
  );
}
