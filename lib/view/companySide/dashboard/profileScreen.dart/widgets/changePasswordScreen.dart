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

  // Any of these mean the request failed — 'code_status' is set by the
  // network layer itself on a transport/HTTP-level failure (bad status,
  // timeout, no internet, ...); 'success'/'status'/'error' are how this
  // backend reports a business-logic failure (e.g. wrong current password)
  // inside an otherwise-200 response. Checking only one of these was the
  // bug: a wrong current password came back as a 200 with success:false,
  // which fell through to the "success" branch and silently popped the
  // screen with no error shown.
  bool _isFailure(Map<String, dynamic> response) {
    if (response['code_status'] == false) return true;
    if (response['success'] == false) return true;
    if (response['status'] == false) return true;
    final error = response['error'];
    if (error != null && error.toString().trim().isNotEmpty) return true;
    return false;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newCtrl.text == _currentCtrl.text) {
      AppToast.error('New password must be different from the current password');
      return;
    }

    setState(() => _isLoading = true);

    late final Map<String, dynamic> response;
    try {
      // This screen owns its own toast messaging end-to-end (see
      // _isFailure) instead of relying on the network layer's automatic
      // toast, since that layer can't tell a business-logic failure
      // reported inside a 200 response from a real success.
      response = await _api.postApi(
        Global.ChangeLoggedInPassword,
        {
          'currentPassword': _currentCtrl.text,
          'newPassword': _newCtrl.text,
        },
        suppressErrorToast: true,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppToast.error('Something went wrong. Please try again.');
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (_isFailure(response)) {
      final message = response['message']?.toString().trim();
      AppToast.error(
        (message != null && message.isNotEmpty)
            ? message
            : 'Could not change password. Please try again.',
      );
      return;
    }

    AppToast.success(
      response['message']?.toString() ?? 'Password changed successfully',
    );
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
