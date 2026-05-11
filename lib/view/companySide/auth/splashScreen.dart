import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/profileForm.dart';
import 'package:new_brand/viewModel/providers/profileProvider/getProfile_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/view/companySide/auth/loginScreen.dart';
import 'package:new_brand/view/companySide/dashboard/company_home_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool _navigated = false;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(); // loading bar ke liye

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
          ),
        );

    checkLoginStatus();
  }

  String _emailFromJwt(String token) {
    try {
      final t = _normalizeToken(token);
      final decoded = JwtDecoder.decode(t);
      return (decoded['email'] ?? "").toString();
    } catch (_) {
      return "";
    }
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
    await Future.delayed(const Duration(seconds: 2));

    final tokenRaw = await LocalStorage.getToken();
    if (tokenRaw == null || tokenRaw.trim().isEmpty) {
      if (!mounted) return;
      _goLogin();
      return;
    }

    final token = _normalizeToken(tokenRaw);

    if (_isTokenExpiredSafe(token)) {
      await LocalStorage.clearToken();
      if (!mounted) return;
      _goLogin();
      return;
    }

    // ✅ optional: FCM should NOT block
    try {
      await LocalStorage.initPushAndSaveToken(
        jwtToken: token,
      ).timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint("FCM init failed on splash: $e");
    }

    // ✅ MUST: Check profile before going home
    final profileProvider = context.read<ProfileFetchProvider>();
    profileProvider.clearProfileCache();
    await profileProvider.getProfileOnce(refresh: true);

    final ok =
        profileProvider.profileData?.message == "Profile fetched successfully";

    if (!mounted) return;

    if (ok) {
      _goHome();
    } else {
      final email = _emailFromJwt(token); // ✅ get email from JWT
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProfileFormScreen(email: email)),
      );
    }
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
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                "assets/images/ShookooSplash.png",
                fit: BoxFit.cover,
              ),
            ),

            // Dark gradient overlay
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xE6000000), // bottom — deep black
                      Color(0x99000000), // mid
                      Color(0x33000000), // top — light
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),

            // Gold shimmer top accent line
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Color(0xFFC9A84C),
                      Color(0xFFE8C96B),
                      Color(0xFFC9A84C),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    SizedBox(height: 80.h),

                    // Animated logo container
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow ring
                            Container(
                              height: 160.h,
                              width: 160.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(
                                    0xFFC9A84C,
                                  ).withOpacity(0.4),
                                  width: 1.5,
                                ),
                              ),
                            ),

                            // Rotating dashed ring
                            RotationTransition(
                              turns: _controller,
                              child: Container(
                                height: 145.h,
                                width: 145.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(
                                      0xFFC9A84C,
                                    ).withOpacity(0.6),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),

                            // Logo circle
                            Container(
                              height: 120.h,
                              width: 120.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFC9A84C),
                                    Color(0xFFE8C96B),
                                    Color(0xFFC9A84C),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFC9A84C,
                                    ).withOpacity(0.5),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.storefront_rounded,
                                color: Colors.white,
                                size: 58.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 40.h),

                    // Brand name
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            Text(
                              "SHOOKOO",
                              style: TextStyle(
                                fontSize: 36.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 6,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            // Gold underline
                            Container(
                              width: 80.w,
                              height: 2,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Color(0xFFC9A84C),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              "SELLER PORTAL",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFC9A84C),
                                letterSpacing: 5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Bottom tagline + loader
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 50.h),
                        child: Column(
                          children: [
                            Text(
                              "Manage. Sell. Grow.",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w300,
                                letterSpacing: 2,
                              ),
                            ),
                            SizedBox(height: 28.h),

                            // Gold loading bar
                            Container(
                              width: 140.w,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: AnimatedBuilder(
                                animation: _controller,
                                builder: (context, _) {
                                  return FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: _controller.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFC9A84C),
                                            Color(0xFFE8C96B),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            SizedBox(height: 20.h),
                            Text(
                              "Powered by Shookoo",
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.white.withOpacity(0.4),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Gold bottom accent line
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Color(0xFFC9A84C),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
