import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/view/companySide/auth/loginScreen.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/view/companySide/dashboard/company_home_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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

    // Rotation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Check token and navigate
    checkLoginStatus();
  }

  // Check token and navigate accordingly
 void checkLoginStatus() async {
  final token = await LocalStorage.getToken();

  await Future.delayed(const Duration(seconds: 2));

  // Token missing?
  if (token == null || token.isEmpty) {
    navigateTo(const LoginScreen());
    return;
  }

  // Check if token expired
  bool isExpired = JwtDecoder.isExpired(token);

  if (isExpired) {
    await LocalStorage.clearToken();
    navigateTo(const LoginScreen());
  } else {
    navigateTo(CompanyHomeScreen());
  }
}

  // Navigation with slide + fade transition
  void navigateTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(begin: const Offset(0, 1), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOut));
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
              // Background image
              Positioned.fill(
                child: Image.asset("assets/images/shookoo_image.png"),
              ),

              // Gradient overlay
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

              // Center content
              Center(
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 100.h),

                      // Rotating icon
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

                      // App Name
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

                      // Tagline
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
