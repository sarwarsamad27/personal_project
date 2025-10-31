import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/view/companySide/auth/verifyCodeScreen.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';

class ForgotScreen extends StatelessWidget {
  ForgotScreen({super.key});
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CustomBgContainer(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: CustomAppContainer(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 70.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20.h),

                      Text(
                        "Forgot Password?",
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColor.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10.h),

                      Text(
                        "Don’t worry! It happens. Please enter the email address associated with your account.",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40.h),

                      CustomTextField(
                        headerText: "Email Address",
                        hintText: "Enter your email",
                        controller: emailController,
                        prefixIcon: Icons.email_outlined,
                      ),
                      SizedBox(height: 30.h),

                      Text(
                        "We will send you a code to reset your password.",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.black45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.h),
                      CustomButton(text: "Next", onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_)=>VerifyCodeScreen()));
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
