import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';

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
  final int? maxLines;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    this.headerText,
    this.hintText,
    this.controller,
    this.isPassword = false,
    this.keyboardType,
    this.prefixIcon,
    this.maxLines = 1,
    this.suffixIcon,
    this.readOnly,
    this.height,
    this.validator,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final ValueNotifier<bool> _obscure = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        if (widget.headerText != null && widget.headerText!.isNotEmpty)
          Text(
            widget.headerText!,
            style: TextStyle(
              color: AppColor.textPrimaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 15.sp,
            ),
          ),
        if (widget.headerText != null && widget.headerText!.isNotEmpty)
          SizedBox(height: 6.h),

        // ✅ TextFormField — Form se connected, validator sirf submit pe chalega
        ValueListenableBuilder<bool>(
          valueListenable: _obscure,
          builder: (context, isObscure, child) {
            return TextFormField(
              controller: widget.controller,
              maxLines: widget.maxLines,
              obscureText: widget.isPassword ? isObscure : false,
              keyboardType: widget.keyboardType ?? TextInputType.text,
              readOnly: widget.readOnly ?? false,
              validator:
                  widget.validator, // ✅ Form handle karega — onChanged nahi
              onChanged:
                  widget.onChanged, // ✅ Sirf callback, koi validation nahi
              autovalidateMode: AutovalidateMode.disabled, // ✅ Real-time off
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
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
                          isObscure ? Icons.visibility_off : Icons.visibility,
                          color: AppColor.primaryColor,
                        ),
                        onPressed: () => _obscure.value = !_obscure.value,
                      )
                    : null,
                // Border styling
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: AppColor.primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(
                    color: AppColor.primaryColor,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: AppColor.errorColor),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(
                    color: AppColor.errorColor,
                    width: 1.5,
                  ),
                ),
                errorStyle: TextStyle(
                  color: AppColor.errorColor,
                  fontSize: 12.sp,
                ),
              ),
            );
          },
        ),

        SizedBox(height: 12.h),
      ],
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0);
  }
}
