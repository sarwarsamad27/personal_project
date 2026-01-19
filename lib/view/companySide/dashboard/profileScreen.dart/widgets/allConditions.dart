import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/view/companySide/auth/loginScreen.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/widgets/infoScreen.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';

class AllCondition extends StatelessWidget {
  Future<void> _showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.18),
                  Colors.white.withOpacity(0.08),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.20),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52.r,
                  height: 52.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.18),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    LucideIcons.logOut,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  "Logout?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "Are you sure you want to logout from your account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 18.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        height: 44.h,
                        text: 'Cancel',
                        second: true,
                        onTap: () => Navigator.pop(ctx, false),
                      ),
                    ),

                    SizedBox(width: 12.w),
                    Expanded(
                      child: CustomButton(
                        height: 44.h,
                        text: 'Logout',
                        onTap: () => Navigator.pop(ctx, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldLogout == true) {
      await _logout(context);
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // Optional: stop push token updates (not required but safe)
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {}

    await LocalStorage.clearToken();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  AllCondition({super.key});
  final List<Map<String, dynamic>> profileOptions = [
    {"icon": LucideIcons.fileText, "label": "Terms & Conditions"},
    {"icon": LucideIcons.phoneCall, "label": "Contact Us"},
    {"icon": LucideIcons.info, "label": "About"},
    {"icon": LucideIcons.helpCircle, "label": "FAQ"},
    {"icon": LucideIcons.logOut, "label": "Logout"},
  ];

  @override
  Widget build(BuildContext context) {
    return CustomAppContainer(
      padding: EdgeInsets.all(15.w),

      child: Column(
        children: profileOptions.map((option) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(option["icon"], color: Colors.white),
            title: Text(
              option["label"],
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: const Icon(LucideIcons.chevronRight, color: Colors.white),
            onTap: () {
              switch (option["label"]) {
                case "Terms & Conditions":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InfoScreen(
                        title: "Terms & Conditions",
                        content: "Here are your Terms & Conditions...",
                      ),
                    ),
                  );
                  break;
                case "Contact Us":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InfoScreen(
                        title: "Contact Us",
                        content:
                            "Contact us at: contact@company.com\nPhone: +92 300 1234567",
                      ),
                    ),
                  );
                  break;
                case "About":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InfoScreen(
                        title: "About",
                        content: "This app is developed by XYZ company...",
                      ),
                    ),
                  );
                  break;
                case "FAQ":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InfoScreen(
                        title: "FAQ",
                        content:
                            "Q1: How to use this app?\nA1: ...\n\nQ2: Payment methods?\nA2: ...",
                      ),
                    ),
                  );
                  break;
                case "Logout":
                  _showLogoutDialog(context);
                  break;
              }
            },
          );
        }).toList(),
      ),
    );
  }
}
