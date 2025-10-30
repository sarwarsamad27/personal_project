import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double height;
  final double width;
  final bool isGradient;
  final bool isDisabled;
  final Color? borderColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.borderColor,
    this.height = 55,
    this.width = double.infinity,
    this.isGradient = true,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        height: height.h,
        width: width.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor ?? Colors.white),
          gradient: isGradient
              ? LinearGradient(
                  colors: [
                    AppColor.primaryColor,
                    AppColor.primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isGradient ? null : AppColor.primaryColor,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
