import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/view/companySide/auth/updatepasswordScreen.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyCodeScreen extends StatelessWidget {
  VerifyCodeScreen({super.key});

  final TextEditingController otpController = TextEditingController();

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
                    vertical: 50.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20.h),

                      /// Title
                      Text(
                        "Verify Code",
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
                        "Please enter the 5-digit verification code sent to your email address.",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 50.h),

                      /// OTP Input
                      PinCodeTextField(
                        appContext: context,
                        length: 5,
                        controller: otpController,
                        animationType: AnimationType.fade,
                        keyboardType: TextInputType.number,
                        textStyle: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primaryColor,
                        ),
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(12.r),
                          fieldHeight: 55.h,
                          fieldWidth: 50.w,
                          activeFillColor: Colors.white,
                          selectedFillColor: Colors.white,
                          inactiveFillColor: Colors.white,
                          activeColor: AppColor.primaryColor,
                          selectedColor: AppColor.primaryColor,
                          inactiveColor: Colors.grey.shade400,
                        ),
                        animationDuration: const Duration(milliseconds: 300),
                        enableActiveFill: true,
                        onChanged: (value) {},
                      ),
                      SizedBox(height: 30.h),

                      /// Resend Text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn’t receive the code? ",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.black54,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // resend code logic
                            },
                            child: Text(
                              "Resend",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 50.h),
                      CustomButton(
                        text: "Verify",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UpdatePasswordScreen(),
                            ),
                          );
                        },
                      ),
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
