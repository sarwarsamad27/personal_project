import 'dart:convert';
import 'package:new_brand/resources/global.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class AuthExpiredException implements Exception {
  final String message;
  AuthExpiredException([this.message = "Session expired"]);
  @override
  String toString() => message;
}

class LocalStorage {
  // ------------------ TOKEN STORAGE ------------------
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  // ------------------ FCM INIT + SAVE ------------------
  /// Call this after login OR on splash if token valid.
  /// Sends FCM token to backend with Authorization Bearer.
  static Future<void> initPushAndSaveToken({required String jwtToken}) async {
    final messaging = FirebaseMessaging.instance;

    // Permission (iOS + Android 13+)
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // Get current token
    final fcmToken = await messaging.getToken();
    if (fcmToken != null && fcmToken.isNotEmpty) {
      // ✅ if backend says 401/403 => throw AuthExpiredException
      await _saveFcmTokenToServer(jwtToken: jwtToken, fcmToken: fcmToken);
    }

    // Token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (newToken.isEmpty) return;
      try {
        final freshJwt = await LocalStorage.getToken(); // ✅ always latest
        if (freshJwt == null || freshJwt.isEmpty) return;

        await _saveFcmTokenToServer(jwtToken: freshJwt, fcmToken: newToken);
        // ignore: avoid_print
        print("FCM token refreshed & saved");
      } on AuthExpiredException catch (e) {
        // ✅ token invalid on server -> clear local
        // ignore: avoid_print
        print("FCM refresh auth expired: $e");
        await LocalStorage.clearToken();
      } catch (e) {
        // ignore: avoid_print
        print("FCM refresh save failed: $e");
      }
    });
  }

  // ------------------ BACKEND CALL ------------------
  static Future<void> _saveFcmTokenToServer({
    required String jwtToken,
    required String fcmToken,
  }) async {
    final uri = Uri.parse(Global.saveFcmToken);

    final resp = await http
        .post(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $jwtToken",
          },
          body: jsonEncode({"token": fcmToken}),
        )
        .timeout(const Duration(seconds: 10));

    // ✅ if auth failed -> throw special exception
    if (resp.statusCode == 401 || resp.statusCode == 403) {
      throw AuthExpiredException(
        "Auth expired (${resp.statusCode}). Please login again.",
      );
    }

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      // ignore: avoid_print
      print("FCM token saved on server");
      return;
    }

    // Helpful debug for backend issues
    throw Exception("FCM save failed (${resp.statusCode}): ${resp.body}");
  }
}
