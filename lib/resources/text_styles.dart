import 'package:flutter/material.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/font_size.dart';
import 'package:new_brand/resources/font_weight.dart';

// refer to design file first

class AppTextStyles {
  // for screen titles eg: Verification Required, Register Account
  static const TextStyle h1 = TextStyle(
    fontWeight: AppFontWeight.w600,
    color: AppColor.textPrimaryColor,
    fontSize: AppFontSizes.font18,
  );
  static const TextStyle buttonTextStyle = TextStyle(
    overflow: TextOverflow.visible,
    fontWeight: AppFontWeight.w400,
    color: AppColor.textWhiteColor,
    fontSize: AppFontSizes.font15,
  );

  static const TextStyle tagTextStyle = TextStyle(
    overflow: TextOverflow.visible,
    fontSize: AppFontSizes.font7,
    fontWeight: AppFontWeight.w600,
  );

  static TextStyle authFieldTextStyle = const TextStyle(
    fontWeight: AppFontWeight.w500,
    fontSize: AppFontSizes.font15,
    color: AppColor.primaryColor,
  );

  static TextStyle otpFieldTextStyle = const TextStyle(
    fontWeight: AppFontWeight.w500,
    fontSize: AppFontSizes.font18,
    color: AppColor.primaryColor,
  );
  static TextStyle inAppFieldTextStyle = const TextStyle(
    fontWeight: AppFontWeight.w600,
    fontSize: AppFontSizes.font12,
    color: AppColor.textPrimaryColor,
  );
}
