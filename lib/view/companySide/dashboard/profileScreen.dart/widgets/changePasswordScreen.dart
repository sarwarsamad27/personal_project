import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customTextFeld.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _api = NetworkApiServices();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final response = await _api.postApi(Global.ChangeLoggedInPassword, {
      'currentPassword': _currentCtrl.text,
      'newPassword': _newCtrl.text,
    });
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response['code_status'] == false) {
      AppToast.error(response['message']?.toString() ?? 'Could not change password');
      return;
    }

    AppToast.success('Password changed successfully');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F1),
      appBar: AppBar(
        backgroundColor: AppColor.appimagecolor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Change Password',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                headerText: "Current Password",
                hintText: "Enter your current password",
                controller: _currentCtrl,
                isPassword: true,
                validator: (v) =>
                    (v == null || v.isEmpty) ? "Enter your current password" : null,
              ),
              CustomTextField(
                headerText: "New Password",
                hintText: "Enter a new password",
                controller: _newCtrl,
                isPassword: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Enter a new password";
                  if (v.length < 6) return "Minimum 6 characters";
                  return null;
                },
              ),
              CustomTextField(
                headerText: "Confirm New Password",
                hintText: "Re-enter the new password",
                controller: _confirmCtrl,
                isPassword: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Confirm your new password";
                  if (v != _newCtrl.text) return "Passwords do not match";
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              CustomButton(
                text: "Update Password",
                isLoading: _isLoading,
                onTap: _isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
