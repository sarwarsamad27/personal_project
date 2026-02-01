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

  bool _navigated = false;

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

  String _normalizeToken(String token) {
    final t = token.trim();
    if (t.toLowerCase().startsWith('bearer ')) {
      return t.substring(7).trim();
    }
    return t;
  }

  bool _isTokenExpiredSafe(String token) {
    try {
      final t = _normalizeToken(token);
      final decoded = JwtDecoder.decode(t);
      if (!decoded.containsKey('exp') || decoded['exp'] == null) return true;
      return JwtDecoder.isExpired(t);
    } catch (_) {
      return true;
    }
  }

  Future<void> checkLoginStatus() async {
    await requestNotifPermissionAndroid13Plus();

    // Keep splash visible
    await Future.delayed(const Duration(seconds: 2));

    final tokenRaw = await LocalStorage.getToken();

    // Token missing?
    if (tokenRaw == null || tokenRaw.trim().isEmpty) {
      if (!mounted) return;
      _goLogin();
      return;
    }

    final token = _normalizeToken(tokenRaw);

    // Token expired locally?
    if (_isTokenExpiredSafe(token)) {
      await LocalStorage.clearToken();
      if (!mounted) return;
      _goLogin();
      return;
    }

    // ✅ Token looks valid locally BUT server may reject it
    try {
      await LocalStorage.initPushAndSaveToken(
        jwtToken: token,
      ).timeout(const Duration(seconds: 8));
    } on AuthExpiredException {
      // ✅ SERVER SAYS TOKEN INVALID -> logout
      await LocalStorage.clearToken();
      if (!mounted) return;
      _goLogin();
      return;
    } catch (e) {
      // FCM failure should NOT stop login flow (network etc)
      // ignore: avoid_print
      print("FCM init failed on splash: $e");
    }

    if (!mounted) return;
    _goHome();
  }

  void _goLogin() {
    if (_navigated) return;
    _navigated = true;
    navigateTo(const LoginScreen());
  }

  void _goHome() {
    if (_navigated) return;
    _navigated = true;
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
