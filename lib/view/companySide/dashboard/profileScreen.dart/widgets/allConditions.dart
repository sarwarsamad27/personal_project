import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/appNav.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/widgets/ContactUs.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/widgets/changePasswordScreen.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/widgets/FAQScreen.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/widgets/TermAndCondition.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/widgets/aboutScreen.dart';
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
                  Colors.white.withValues(alpha: 0.18),
                  Colors.white.withValues(alpha: 0.08),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
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
                    color: Colors.white.withValues(alpha: 0.12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    LucideIcons.log_out,
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
                    color: Colors.white.withValues(alpha: 0.85),
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

    if (shouldLogout == true && context.mounted) {
      await _logout(context);
    }
  }

  Future<void> _logout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: AppColor.appimagecolor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SpinKitThreeBounce(color: AppColor.whiteColor, size: 28.0),
                SizedBox(height: 16.h),
                Text(
                  "Logging out...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final jwtToken = await LocalStorage.getToken();
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (jwtToken != null && jwtToken.isNotEmpty && fcmToken != null && fcmToken.isNotEmpty) {
        await LocalStorage.removeFcmTokenFromServer(
          jwtToken: jwtToken,
          fcmToken: fcmToken,
        ).timeout(const Duration(seconds: 3));
      }
      await FirebaseMessaging.instance.deleteToken().timeout(const Duration(seconds: 3));
    } catch (_) {}

    await AppNav.forceLogoutToLogin();
  }

  AllCondition({super.key});
  final List<Map<String, dynamic>> profileOptions = [
    {"icon": LucideIcons.file_text, "label": "Terms & Conditions"},
    {"icon": LucideIcons.phone_call, "label": "Contact Us"},
    {"icon": LucideIcons.info, "label": "About"},
    {"icon": LucideIcons.circle_question_mark, "label": "FAQ"},
    {"icon": LucideIcons.key_round, "label": "Change Password"},
    {"icon": LucideIcons.log_out, "label": "Logout"},
  ];

  @override
  Widget build(BuildContext context) {
    return CustomAppContainer(
      padding: EdgeInsets.all(15.w),

      child: Material(
        type: MaterialType.transparency,
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
            trailing: const Icon(LucideIcons.chevron_right, color: Colors.white),
            onTap: () {
              switch (option["label"]) {
                case "Terms & Conditions":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TermAndConditionScreen(
                     
                      ),
                    ),
                  );
                  break;
                case "Contact Us":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ContactUsScreen(),
                    ),
                  );
                  break;
                case "About":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AboutScreen(
                       ),
                    ),
                  );
                  break;
                case "FAQ":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FAQScreen(
                     ),
                    ),
                  );
                  break;
                case "Change Password":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
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
      ),
    );
  }
}
