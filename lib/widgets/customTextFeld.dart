import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/toast.dart';

class CustomTextField extends StatefulWidget {
  final String? headerText;
  final String? hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;
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
    this.keyboardType,
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
  final ValueNotifier<bool> _obscure = ValueNotifier<bool>(true);
  final ValueNotifier<String?> _errorText = ValueNotifier<String?>(null);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header Text
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
        ValueListenableBuilder<String?>(
          valueListenable: _errorText,
          builder: (context, error, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: error == null
                          ? AppColor.primaryColor
                          : AppColor.errorColor,
                    ),
                  ),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _obscure,
                    builder: (context, isObscure, child) {
                      return TextField(
                        controller: widget.controller,
                        obscureText: widget.isPassword ? isObscure : false,
                        keyboardType: widget.keyboardType ?? TextInputType.text,
                        readOnly: widget.readOnly ?? false,
                        onChanged: (value) {
                          if (widget.validator != null) {
                            final message = widget.validator!(value);
                            _errorText.value = message;
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
                              ? Icon(
                                  widget.prefixIcon,
                                  color: AppColor.primaryColor,
                                )
                              : null,
                          suffixIcon: widget.isPassword
                              ? IconButton(
                                  icon: Icon(
                                    isObscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColor.primaryColor,
                                  ),
                                  onPressed: () =>
                                      _obscure.value = !_obscure.value,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),

                /// Error Text Under Field
                if (error != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h, left: 4.w),
                    child: Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 12.sp),
                    ),
                  ),
              ],
            );
          },
        ),

        SizedBox(height: 12.h),
      ],
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0);
  }
}
