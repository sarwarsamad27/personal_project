import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';

class CustomTextField extends StatefulWidget {
  final String headerText;
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;

  const CustomTextField({
    super.key,
    required this.headerText,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header Text
        Text(
          widget.headerText,
          style: TextStyle(
            color: AppColor.textPrimaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
        ),
        SizedBox(height: 6.h),

        /// TextField Container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: widget.isPassword ? obscure : false,
            style: TextStyle(color: AppColor.textPrimaryColor, fontSize: 15.sp),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 14.h,
              ),
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: AppColor.textSecondaryColor.withOpacity(0.7),
                fontSize: 14.sp,
              ),
              border: InputBorder.none,

              /// Prefix Icon
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: AppColor.primaryColor)
                  : null,

              /// Suffix Eye Icon (for Password)
              suffixIcon: widget.isPassword
                  ? IconButton(
                      onPressed: () {
                        setState(() => obscure = !obscure);
                      },
                      icon: Icon(
                        obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColor.primaryColor,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
