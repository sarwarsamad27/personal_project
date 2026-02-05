import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/view/companySide/auth/forgotScreen.dart';
import 'package:new_brand/view/companySide/auth/signUpScreen.dart';
import 'package:new_brand/view/companySide/dashboard/company_home_screen.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/profileForm.dart';
import 'package:new_brand/viewModel/providers/AuthProvider/appleLogin_provider.dart';
import 'package:new_brand/viewModel/providers/AuthProvider/googleLogin_provider.dart';
import 'package:new_brand/viewModel/providers/AuthProvider/login_provider.dart';
import 'package:new_brand/viewModel/providers/profileProvider/getProfile_provider.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';
import 'package:new_brand/widgets/social_button.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoginProvider>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.appimagecolor,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_rounded,
                        size: 70.sp,
                        color: AppColor.primaryColor,
                      ),
                      SizedBox(height: 18.h),

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
                          color: AppColor.textSecondaryColor.withOpacity(0.8),
                        ),
                      ),
                      SizedBox(height: 30.h),

                      CustomTextField(
                        headerText: "Email Address",
                        hintText: "Enter your email",
                        controller: provider.emailController,
                        prefixIcon: Icons.email_outlined,
                      ),
                      SizedBox(height: 18.h),

                      CustomTextField(
                        headerText: "Password",
                        hintText: "Enter your password",
                        controller: provider.passwordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline,
                      ),
                      SizedBox(height: 12.h),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ForgotScreen()),
                            );
                          },
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

                      CustomButton(
                        text: "Login",
                        onTap: () async {
                          final loginProvider = context.read<LoginProvider>();
                          final profileProvider = context
                              .read<ProfileFetchProvider>();
                          final nav = Navigator.of(context);

                          loginProvider.clearError();

                          await loginProvider.loginProvider(
                            email: loginProvider.emailController.text.trim(),
                            password: loginProvider.passwordController.text
                                .trim(),
                          );

                          final jwt = loginProvider.loginData?.token;
                          if (jwt == null || jwt.isEmpty) {
                            AppToast.error(
                              loginProvider.errorMessage ??
                                  "Invalid email or password",
                            );
                            return;
                          }

                          final userEmail = loginProvider.emailController.text
                              .trim();

                          loginProvider.emailController.clear();
                          loginProvider.passwordController.clear();

                          profileProvider.clearProfileCache();
                          await profileProvider.getProfileOnce(refresh: true);

                          final ok =
                              profileProvider.profileData?.message ==
                              "Profile fetched successfully";

                          if (!nav.mounted) return;

                          if (ok) {
                            try {
                              await LocalStorage.initPushAndSaveToken(
                                jwtToken: jwt,
                              );
                            } catch (e) {
                              debugPrint("⚠️ FCM save skipped: $e");
                            }

                            nav.pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => CompanyHomeScreen(),
                              ),
                            );
                          } else {
                            nav.pushReplacement(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProfileFormScreen(email: userEmail),
                              ),
                            );
                          }
                        },
                      ),

                      SizedBox(height: 20.h),

                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey.withOpacity(0.4),
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
                              color: Colors.grey.withOpacity(0.4),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          socialButton(
                            icon: FontAwesomeIcons.google,
                            color: Colors.redAccent,
                            onTap: () async {
                              final googleProvider = context
                                  .read<CompanyGoogleLoginProvider>();
                              final profileProvider = context
                                  .read<ProfileFetchProvider>();
                              final nav = Navigator.of(context);

                              googleProvider.clearError();
                              await googleProvider.loginWithGoogle();

                              final jwt = googleProvider.loginData?.token;
                              if (jwt == null || jwt.isEmpty) {
                                AppToast.error(
                                  googleProvider.errorMessage ??
                                      "Google login failed",
                                );
                                return;
                              }

                              profileProvider.clearProfileCache();
                              await profileProvider.getProfileOnce(
                                refresh: true,
                              );

                              final ok =
                                  profileProvider.profileData?.message ==
                                  "Profile fetched successfully";

                              if (!nav.mounted) return;

                              if (ok) {
                                try {
                                  await LocalStorage.initPushAndSaveToken(
                                    jwtToken: jwt,
                                  );
                                } catch (e) {
                                  debugPrint("⚠️ FCM save skipped: $e");
                                }

                                nav.pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => CompanyHomeScreen(),
                                  ),
                                );
                              } else {
                                final email =
                                    googleProvider.loginData?.user?.email ?? "";
                                nav.pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProfileFormScreen(email: email),
                                  ),
                                );
                              }
                            },
                          ),
                          SizedBox(width: 25.w),
                          socialButton(
                            icon: Icons.apple,
                            color: Colors.black,
                            onTap: () async {
                              final appleProvider = context
                                  .read<CompanyAppleLoginProvider>();
                              final profileProvider = context
                                  .read<ProfileFetchProvider>();
                              final nav = Navigator.of(context);

                              appleProvider.clearError();
                              await appleProvider.loginWithApple();

                              final jwt = appleProvider.loginData?.token;
                              if (jwt == null || jwt.isEmpty) {
                                AppToast.error(
                                  appleProvider.errorMessage ??
                                      "Apple login failed",
                                );
                                return;
                              }

                              profileProvider.clearProfileCache();
                              await profileProvider.getProfileOnce(
                                refresh: true,
                              );

                              final ok =
                                  profileProvider.profileData?.message ==
                                  "Profile fetched successfully";

                              if (!nav.mounted) return;

                              if (ok) {
                                try {
                                  await LocalStorage.initPushAndSaveToken(
                                    jwtToken: jwt,
                                  );
                                } catch (e) {
                                  debugPrint("⚠️ FCM save skipped: $e");
                                }

                                nav.pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => CompanyHomeScreen(),
                                  ),
                                );
                              } else {
                                final email =
                                    appleProvider.loginData?.user?.email ?? "";
                                nav.pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProfileFormScreen(email: email),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 25.h),

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
    );
  }
}
