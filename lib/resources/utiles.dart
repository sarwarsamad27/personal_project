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



 }
