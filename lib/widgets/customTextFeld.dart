import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';

class CustomTextField extends StatefulWidget {
  final String? headerText;
  final String? hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final double? height;
  final bool? readOnly;
  final Function(String)? onChanged; // ✅ optional onChanged added

  const CustomTextField({
    super.key,
    this.headerText,
    this.hintText,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.readOnly,
    this.height,
    this.onChanged, // ✅ optional parameter
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscure = true;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Disable focus when readOnly = true
    if (widget.readOnly == true) {
      _focusNode = AlwaysDisabledFocusNode();
    }
  }

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

        /// TextField Container
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColor.primaryColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            focusNode: _focusNode,
            readOnly: widget.readOnly ?? false,
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: widget.isPassword ? obscure : false,
            expands: widget.height != null,
            maxLines: widget.height != null ? null : 1,
            minLines: widget.height != null ? null : 1,
            style: TextStyle(color: AppColor.textPrimaryColor, fontSize: 15.sp),

            // ✅ optional onChanged callback (safe call)
            onChanged: widget.onChanged,

            decoration: InputDecoration(
              isCollapsed: true,
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

/// 👇 Custom focus node that disables focus completely
class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
