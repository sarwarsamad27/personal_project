import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/view/companySide/auth/loginScreen.dart';
import 'package:new_brand/view/companySide/dashboard/company_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    checkLoginStatus();
  }

  Future<void> requestNotifPermissionAndroid13Plus() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  Future<void> checkLoginStatus() async {
    await requestNotifPermissionAndroid13Plus();
    final token = await LocalStorage.getToken();

    // Keep splash visible
    await Future.delayed(const Duration(seconds: 2));

    // Token missing?
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      navigateTo(const LoginScreen());
      return;
    }

    // Token expired?
    final isExpired = JwtDecoder.isExpired(token);
    if (isExpired) {
      await LocalStorage.clearToken();
      if (!mounted) return;
      navigateTo(const LoginScreen());
      return;
    }

    // ✅ Token valid: register FCM token BEFORE going home
    try {
      // Don't block forever
      await LocalStorage.initPushAndSaveToken(
        jwtToken: token,
      ).timeout(const Duration(seconds: 8));
    } catch (e) {
      // FCM failure should NOT stop login flow
      // ignore: avoid_print
      print("FCM init failed on splash: $e");
    }

    if (!mounted) return;
    navigateTo(CompanyHomeScreen());
  }

  void navigateTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOut));
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, child) {
        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset("assets/images/shookoo_image.png"),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.3),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Center(
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 100.h),
                      RotationTransition(
                        turns: _controller,
                        child: Container(
                          height: 130.h,
                          width: 130.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.shopping_bag_rounded,
                            color: AppColor.primaryColor,
                            size: 65.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 30.h),
                      Text(
                        "Shookoo Store",
                        style: TextStyle(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.3,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        "Everything you need, in one place!",
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
