import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/toast.dart';

class CustomTextField extends StatefulWidget {
  final String? headerText;
  final String? hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final double? height;
  final bool? readOnly;

  final String? Function(String?)? validator; // ✅ ADDED
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    this.headerText,
    this.hintText,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly,
    this.height,
    this.validator, // ✅
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscure = true;
  String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header Text
        /// 
        Text(
          widget.headerText ?? '',
          style: TextStyle(
            color: AppColor.textPrimaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
        ),
        SizedBox(height: 6.h),

        /// TextField Box
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: errorText == null
                  ? AppColor.primaryColor
                  : AppColor.errorColor,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.isPassword ? obscure : false,
            keyboardType: widget.keyboardType,
            readOnly: widget.readOnly ?? false,
            onChanged: (value) {
              if (widget.validator != null) {
                final message = widget.validator!(value);

                setState(() => errorText = message);

                if (message != null) {
                  AppToast.error(message);
                }
              }

              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
            },

            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: AppColor.textSecondaryColor.withOpacity(0.7),
                fontSize: 14.sp,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 14.h,
              ),

              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: AppColor.primaryColor)
                  : null,

              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColor.primaryColor,
                      ),
                      onPressed: () => setState(() => obscure = !obscure),
                    )
                  : null,
            ),
          ),
        ),

        /// Error Text Under Field
        if (errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w),
            child: Text(
              errorText!,
              style: TextStyle(color: Colors.red, fontSize: 12.sp),
            ),
          ),

        SizedBox(height: 12.h),
      ],
    );
  }
}
