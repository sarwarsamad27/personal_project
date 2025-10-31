import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/view/companySide/auth/loginScreen.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';

class UpdatePasswordScreen extends StatelessWidget {
  UpdatePasswordScreen({super.key});

  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CustomBgContainer(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: 24.w,
                  right: 24.w,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 30.h,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// Top Content
                        CustomAppContainer(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 50.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 20.h),

                              /// Title
                              Text(
                                "Update Password",
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.primaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10.h),

                              /// Subtitle
                              Text(
                                "Your new password must be different from previously used passwords.",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black54,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 50.h),

                              /// New Password Field
                              CustomTextField(
                                headerText: "New Password",
                                hintText: "Enter new password",
                                controller: newPasswordController,
                                prefixIcon: Icons.lock_outline,
                                isPassword: true,
                              ),
                              SizedBox(height: 30.h),

                              /// Confirm Password Field
                              CustomTextField(
                                headerText: "Confirm Password",
                                hintText: "Re-enter new password",
                                controller: confirmPasswordController,
                                prefixIcon: Icons.lock_outline,
                                isPassword: true,
                              ),
                              SizedBox(height: 20.h),

                              /// Info Text
                              Text(
                                "Make sure both passwords match.",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.black45,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 50.h),
                              CustomButton(
                                text: "Update Password",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LoginScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
