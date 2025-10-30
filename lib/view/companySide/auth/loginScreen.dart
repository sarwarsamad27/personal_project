import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/view/companySide/auth/signUpScreen.dart';
import 'package:new_brand/view/companySide/dashboard/company_home_screen.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';
import 'package:new_brand/widgets/social_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
        return Scaffold(
          /// ❌ Prevent keyboard from resizing background
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              /// 🔹 Background Image (exactly like splash)
              Positioned.fill(
                child: Image.asset("assets/images/shookoo_image.png"),
              ),

              /// 🔹 Login Content
              CustomBgContainer(
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
                                "Welcome Back 👋",
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.textPrimaryColor,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                "Login to continue your journey",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColor.textSecondaryColor
                                      .withOpacity(0.8),
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
                              SizedBox(height: 12.h),

                              /// Forgot Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                      color: AppColor.textPrimaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.h),

                              /// Login Button
                              CustomButton(
                                text: "Login",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CompanyHomeScreen(),
                                    ),
                                  );
                                  print("Login Pressed!");
                                },
                              ),

                              SizedBox(height: 20.h),

                              /// Divider
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey.withOpacity(0.4),
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                    ),
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
                                      color: Colors.grey.withOpacity(0.4),
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 20.h),

                              /// Login with Google / Apple Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  socialButton(
                                    icon: FontAwesomeIcons.google,
                                    color: Colors.redAccent,
                                    onTap: () => print("Google login"),
                                  ),
                                  SizedBox(width: 25.w),
                                  socialButton(
                                    icon: Icons.apple,
                                    color: Colors.black,
                                    onTap: () => print("Apple login"),
                                  ),
                                ],
                              ),

                              SizedBox(height: 25.h),

                              /// Sign Up Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don’t have an account? ",
                                    style: TextStyle(
                                      color: AppColor.textSecondaryColor,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SignUpScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Sign Up",
                                      style: TextStyle(
                                        color: AppColor.textPrimaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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



 //   Container(
                  //     width: double.infinity,
                  //     padding: EdgeInsets.symmetric(
                  //       horizontal: 20.w,
                  //       vertical: 30.h,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: Colors.white.withOpacity(0.65),
                  //       borderRadius: BorderRadius.circular(22.r),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.black.withOpacity(0.15),
                  //           blurRadius: 20,
                  //           offset: const Offset(0, 6),
                  //         ),
                  //       ],
                  //     ),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       children: [
                  //         /// App Logo
                  //         Icon(
                  //           Icons.shopping_bag_rounded,
                  //           size: 70.sp,
                  //           color: AppColor.primaryColor,
                  //         ),
                  //         SizedBox(height: 18.h),

                  //         /// Header
                  //         Text(
                  //           "Create Account ✨",
                  //           style: TextStyle(
                  //             fontSize: 24.sp,
                  //             fontWeight: FontWeight.bold,
                  //             color: AppColor.textPrimaryColor,
                  //           ),
                  //         ),
                  //         SizedBox(height: 6.h),
                  //         Text(
                  //           "Join us and start your journey today!",
                  //           style: TextStyle(
                  //             fontSize: 14.sp,
                  //             color: AppColor.textSecondaryColor.withOpacity(
                  //               0.8,
                  //             ),
                  //           ),
                  //         ),
                  //         SizedBox(height: 30.h),

                  //         /// Email Field
                  //         CustomTextField(
                  //           headerText: "Email Address",
                  //           hintText: "Enter your email",
                  //           controller: emailController,
                  //           prefixIcon: Icons.email_outlined,
                  //         ),
                  //         SizedBox(height: 18.h),

                  //         /// Password Field
                  //         CustomTextField(
                  //           headerText: "Password",
                  //           hintText: "Enter your password",
                  //           controller: passwordController,
                  //           isPassword: true,
                  //           prefixIcon: Icons.lock_outline,
                  //         ),
                  //         SizedBox(height: 18.h),

                  //         /// Confirm Password Field
                  //         CustomTextField(
                  //           headerText: "Confirm Password",
                  //           hintText: "Re-enter your password",
                  //           controller: confirmPasswordController,
                  //           isPassword: true,
                  //           prefixIcon: Icons.lock_reset_outlined,
                  //         ),
                  //         SizedBox(height: 25.h),

                  //         /// Create Account Button
                  //         CustomButton(
                  //           text: "Create Account",
                  //           onTap: () {
                  //             print("Sign Up Pressed!");
                  //           },
                  //         ),

                  //         SizedBox(height: 25.h),

                  //         /// Divider
                  //         Row(
                  //           children: [
                  //             Expanded(
                  //               child: Divider(
                  //                 color: Colors.grey.withOpacity(0.4),
                  //                 thickness: 1,
                  //               ),
                  //             ),
                  //             Padding(
                  //               padding: EdgeInsets.symmetric(horizontal: 10.w),
                  //               child: Text(
                  //                 "Or continue with",
                  //                 style: TextStyle(
                  //                   color: AppColor.textSecondaryColor,
                  //                   fontSize: 13.sp,
                  //                 ),
                  //               ),
                  //             ),
                  //             Expanded(
                  //               child: Divider(
                  //                 color: Colors.grey.withOpacity(0.4),
                  //                 thickness: 1,
                  //               ),
                  //             ),
                  //           ],
                  //         ),

                  //         SizedBox(height: 20.h),

                  //         Row(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             Text(
                  //               "Already have an account? ",
                  //               style: TextStyle(
                  //                 color: AppColor.textSecondaryColor,
                  //                 fontSize: 14.sp,
                  //               ),
                  //             ),
                  //             GestureDetector(
                  //               onTap: () {
                  //                 Navigator.pushReplacement(
                  //                   context,
                  //                   MaterialPageRoute(
                  //                     builder: (context) => const LoginScreen(),
                  //                   ),
                  //                 );
                  //               },
                  //               child: Text(
                  //                 "Login",
                  //                 style: TextStyle(
                  //                   color: AppColor.primaryColor,
                  //                   fontWeight: FontWeight.bold,
                  //                   fontSize: 14.sp,
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                 