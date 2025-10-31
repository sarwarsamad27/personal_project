import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';
import 'package:new_brand/view/companySide/auth/loginScreen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: CustomBgContainer(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: CustomAppContainer(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 30.h,
                    ),

                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /// App Logo
                          Icon(
                            Icons.shopping_bag_rounded,
                            size: 70.sp,
                            color: AppColor.primaryColor,
                          ),
                          SizedBox(height: 18.h),

                          /// Header
                          Text(
                            "Create Account ✨",
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColor.textPrimaryColor,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            "Join us and start your journey today!",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColor.textSecondaryColor.withOpacity(
                                0.8,
                              ),
                            ),
                          ),
                          SizedBox(height: 30.h),

                          /// Email Field
                          CustomTextField(
                            headerText: "Email Address",
                            hintText: "Enter your email",
                            controller: emailController,
                            prefixIcon: Icons.email_outlined,
                          ),
                          SizedBox(height: 18.h),

                          /// Password Field
                          CustomTextField(
                            headerText: "Password",
                            hintText: "Enter your password",
                            controller: passwordController,
                            isPassword: true,
                            prefixIcon: Icons.lock_outline,
                          ),
                          SizedBox(height: 18.h),

                          /// Confirm Password Field
                          CustomTextField(
                            headerText: "Confirm Password",
                            hintText: "Re-enter your password",
                            controller: confirmPasswordController,
                            isPassword: true,
                            prefixIcon: Icons.lock_reset_outlined,
                          ),
                          SizedBox(height: 25.h),

                          /// Create Account Button
                          CustomButton(
                            text: "Create Account",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LoginScreen(),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: 25.h),

                          /// Login Button
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: AppColor.blackcolor,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                child: Text(
                                  "Or continue with",
                                  style: TextStyle(
                                    color: AppColor.textSecondaryColor,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: AppColor.blackcolor,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 20.h),

                          /// Divider
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  color: AppColor.textSecondaryColor,
                                  fontSize: 14.sp,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    color: AppColor.textPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
