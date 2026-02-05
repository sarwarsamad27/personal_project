import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/appNav.dart';

class AppToast {
  static void _showFlushbar({
    required String message,
    required Color color,
    required IconData icon,
    String? title,
  }) {
    final context = appNavKey.currentContext;
    if (context == null) return;

    // ✅ FIX: show flushbar in next frame to avoid Navigator _debugLocked
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = appNavKey.currentContext;
      if (ctx == null) return;

      // ✅ If navigator is in transition / locked, don't push a route
      final nav = Navigator.maybeOf(ctx);
      if (nav == null) return;

      Flushbar(
        titleText: title != null
            ? Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              )
            : null,
        messageText: Text(
          message,
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.white,
            height: 1.4,
          ),
        ),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        duration: const Duration(seconds: 4),
        flushbarPosition: FlushbarPosition.TOP,
        borderRadius: BorderRadius.circular(20),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(16),
        barBlur: 10,
        backgroundColor: color.withOpacity(0.7),
        backgroundGradient: LinearGradient(
          colors: [color.withOpacity(0.85), color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadows: [
          BoxShadow(
            color: color.withOpacity(0.4),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
        dismissDirection: FlushbarDismissDirection.VERTICAL,
        forwardAnimationCurve: Curves.elasticOut,
        reverseAnimationCurve: Curves.easeInCirc,
        animationDuration: const Duration(milliseconds: 600),
        leftBarIndicatorColor: color,
        shouldIconPulse: true,
      ).show(ctx);
    });
  }

  static void show(String message) {
    _showFlushbar(
      message: message,
      color: Colors.black87,
      icon: Icons.info_outline,
    );
  }

  static void success(String message) {
    _showFlushbar(
      message: message,
      color: AppColor.successColor,
      icon: Icons.check_circle_outline,
      title: "Success",
    );
  }

  static void error(String message) {
    _showFlushbar(
      message: message,
      color: AppColor.errorColor,
      icon: Icons.error_outline,
      title: "Error",
    );
  }

  static void warning(String message) {
    _showFlushbar(
      message: message,
      color: Colors.orange,
      icon: Icons.warning_amber_rounded,
      title: "Warning",
    );
  }

  static void info(String message) {
    _showFlushbar(
      message: message,
      color: Colors.blueAccent,
      icon: Icons.info_outline,
      title: "Info",
    );
  }
}
