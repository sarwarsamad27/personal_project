import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class Utils {
  static SpinKitThreeBounce spinkit = SpinKitThreeBounce(
    // color: AppColor.lightScheme.secondary,
  );
  static SpinKitThreeBounce spinkitCircle({double? size}) => SpinKitThreeBounce(
        // color: AppColor.lightScheme.primary,
        size: size ?? 50.0,
      );

  static Future<dynamic> loader(BuildContext context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => PopScope(
        canPop: false,
        child: spinkit,
      ),
    );
  }

  // ── Order payment display helpers ─────────────────────────────────────────
  // Centralized so every order list/detail screen shows the same wording
  // instead of each screen hardcoding "Cash on Delivery".
  static bool isOrderPrepaid(String? paymentStatus) => paymentStatus == 'paid';

  static String paymentLabel(String? paymentMethod, String? paymentStatus) {
    final prepaid = isOrderPrepaid(paymentStatus);
    switch (paymentMethod) {
      case 'wallet':
        return prepaid ? 'Paid via Wallet' : 'Wallet Payment Pending';
      case 'jazzcash':
        return prepaid ? 'Paid via JazzCash' : 'JazzCash Payment Pending';
      case 'cod':
      default:
        return 'Cash on Delivery';
    }
  }

  static Color paymentColor(String? paymentStatus) =>
      isOrderPrepaid(paymentStatus) ? Colors.green : Colors.orange;

  static IconData paymentIcon(String? paymentStatus) =>
      isOrderPrepaid(paymentStatus)
          ? Icons.verified_rounded
          : Icons.payments_outlined;
 }
