// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:new_brand/route/routes.dart';
import 'package:new_brand/view/companySide/auth/splashScreen.dart';

class AppPages {
  static Map<String, WidgetBuilder> getRoutes() {
    return {RoutesName.splashScreen: (context) => const SplashScreen()};
  }
}
