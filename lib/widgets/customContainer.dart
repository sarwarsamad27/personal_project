import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? blurRadius;
  final Color? startColor;
  final Color? endColor;
  final LinearGradient? gradient;
  final Color? color;
  final Color? shadow;
  final double? height;
  final double? width;
  final Color? borderColor;
  final Border? border;

  const CustomAppContainer({
    super.key,
    this.child,
    this.padding,
    this.borderRadius,
    this.blurRadius,
    this.startColor,
    this.color,
    this.borderColor,
    this.endColor,
    this.height,
    this.gradient,
    this.width,
    this.border,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding:
          padding ?? EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: color ?? Colors.white.withOpacity(0.2),
        borderRadius: borderRadius ?? BorderRadius.circular(20.r),
        border: Border.all(color: borderColor ?? Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
