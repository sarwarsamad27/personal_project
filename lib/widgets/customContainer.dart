import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double? blurRadius;
  final Color? startColor;
  final Color? endColor;
  final LinearGradient? gradient;
  final Color? color;
  final Color? shadow;
  final double? height;
  final double? width;

  const CustomAppContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blurRadius,
    this.startColor,
    this.color,
    this.endColor,
    this.height,
    this.gradient,
    this.width,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? null,
      width: width ?? double.infinity,
      padding: padding ?? EdgeInsets.symmetric(vertical: 30.h),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        gradient:
            gradient ??
            LinearGradient(
              colors: [
                startColor ?? Colors.white.withOpacity(0.65),
                endColor ?? Colors.white.withOpacity(0.65),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        color: color ?? Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(borderRadius ?? 22.r),
      ),
      child: child,
    );
  }
}
