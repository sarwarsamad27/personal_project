import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/connectivity_plus.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/viewModel/providers/AuthProvider/signUp_provider.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';
import 'package:new_brand/view/companySide/auth/loginScreen.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final provider = Provider.of<SignUpProvider>(context, listen: false);

    final formKey = GlobalKey<FormState>();

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
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
                        child: Form(
                          key: formKey,
                          autovalidateMode: AutovalidateMode.disabled,
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
                                "Create Account",
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
                                  color: AppColor.textSecondaryColor
                                      .withOpacity(0.8),
                                ),
                              ),
                              SizedBox(height: 30.h),

                              CustomTextField(
                                headerText: "Email Address",
                                hintText: "Enter your email",
                                controller: emailController,
                                prefixIcon: Icons.email_outlined,
                              ),

                              SizedBox(height: 18.h),

                              CustomTextField(
                                headerText: "Password",
                                hintText: "Enter your password",
                                controller: passwordController,
                                isPassword: true,
                                prefixIcon: Icons.lock_outline,
                              ),

                              SizedBox(height: 18.h),

                              CustomTextField(
                                headerText: "Confirm Password",
                                hintText: "Re-enter your password",
                                controller: confirmPasswordController,
                                isPassword: true,
                                prefixIcon: Icons.lock_reset_outlined,
                              ),

                              SizedBox(height: 25.h),

                              CustomButton(
                                text: "Create Account",
                                onTap: () async {
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }

                                  if (!await isConnected()) {
                                    AppToast.error("No internet connection");
                                    return;
                                  }

                                  await provider
                                      .signUpProvider(
                                        email: emailController.text.trim(),
                                        password: passwordController.text
                                            .trim(),
                                        confirmPassword:
                                            confirmPasswordController.text
                                                .trim(),
                                      )
                                      .then(
                                        (value) => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const LoginScreen(),
                                          ),
                                        ),
                                      );

                                  if (provider.signUpData?.newUser != null) {
                                    /// CLEAR ALL FIELDS
                                    emailController.clear();
                                    passwordController.clear();
                                    confirmPasswordController.clear();

                                    AppToast.success("Signup Successful");
                                  } else {
                                    AppToast.error(
                                      provider.errorMessage ?? "Signup Failed",
                                    );
                                  }
                                },
                              ),

                              SizedBox(height: 25.h),

                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: AppColor.blackcolor,
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
                                      color: AppColor.blackcolor,
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 20.h),

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
                                          builder: (context) =>
                                              const LoginScreen(),
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
              Consumer<SignUpProvider>(
                builder: (context, value, child) {
                  return value.loading
                      ? Container(
                          height: double.infinity,
                          width: double.infinity,
                          color: Colors.black.withOpacity(0.3),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 4),
                          ),
                        )
                      : const SizedBox();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
