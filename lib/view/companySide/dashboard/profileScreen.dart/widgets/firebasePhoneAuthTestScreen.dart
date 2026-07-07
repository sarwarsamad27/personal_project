// TEST/EXPLORATION SCREEN ONLY — not wired into any real feature.
// Lets you try Firebase Phone Auth (send OTP -> enter code -> verify) in
// isolation, side-by-side with the VerifyWay-based withdrawal OTP flow.
// Safe to delete once you're done evaluating it.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customTextFeld.dart';

class FirebasePhoneAuthTestScreen extends StatefulWidget {
  const FirebasePhoneAuthTestScreen({super.key});

  @override
  State<FirebasePhoneAuthTestScreen> createState() =>
      _FirebasePhoneAuthTestScreenState();
}

class _FirebasePhoneAuthTestScreenState
    extends State<FirebasePhoneAuthTestScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  String? _verificationId;
  bool _codeSent = false;
  bool _loading = false;
  String _log = '';

  // Every Firebase callback below can fire after this screen has been
  // popped (e.g. the user navigated back while a callback was still
  // in-flight) — guard every setState with `mounted` to avoid
  // "setState() called after dispose()".
  void _appendLog(String line) {
    if (!mounted) return;
    setState(() => _log = '$_log\n$line'.trim());
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      AppToast.show('Enter a phone number (e.g. +923001234567)');
      return;
    }

    if (mounted) setState(() => _loading = true);
    _appendLog('Sending OTP to $phone via Firebase...');

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),

      // Android only, fires automatically if the device can auto-read the
      // SMS (SMS Retriever) without the user typing anything.
      verificationCompleted: (PhoneAuthCredential credential) async {
        _appendLog('✅ Auto-verified (Android SMS auto-retrieval)');
        await _signInWithCredential(credential);
      },

      verificationFailed: (FirebaseAuthException e) {
        _appendLog('❌ verificationFailed: ${e.code} — ${e.message}');
        if (mounted) setState(() => _loading = false);
      },

      codeSent: (String verificationId, int? resendToken) {
        _appendLog('📨 Code sent. verificationId received.');
        _verificationId = verificationId;
        if (!mounted) return;
        setState(() {
          _codeSent = true;
          _loading = false;
        });
      },

      codeAutoRetrievalTimeout: (String verificationId) {
        _appendLog('⏱️ Auto-retrieval timed out (enter code manually).');
        _verificationId = verificationId;
      },
    );
  }

  Future<void> _verifyOtp() async {
    final code = _codeController.text.trim();
    if (_verificationId == null || code.isEmpty) {
      AppToast.show('Enter the code first');
      return;
    }

    setState(() => _loading = true);
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: code,
    );
    await _signInWithCredential(credential);
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final result = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      _appendLog(
        '✅ Verified! Firebase phone: ${result.user?.phoneNumber}',
      );
      // This is just a verification check, not a real login — don't leave
      // a lingering Firebase session sitting around.
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      _appendLog('❌ signInWithCredential failed: ${e.code} — ${e.message}');
    } catch (e) {
      _appendLog('❌ Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Phone Auth Test')),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                hintText: '+923001234567',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12.h),
              CustomButton(
                text: _loading ? 'Working...' : 'Send OTP',
                onTap: _loading ? null : _sendOtp,
              ),
              if (_codeSent) ...[
                SizedBox(height: 20.h),
                CustomTextField(
                  hintText: 'Enter 6-digit code',
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12.h),
                CustomButton(
                  text: _loading ? 'Verifying...' : 'Verify',
                  onTap: _loading ? null : _verifyOtp,
                ),
              ],
              SizedBox(height: 24.h),
              Text(
                'Log',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColor.textPrimaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  _log.isEmpty ? '(nothing yet)' : _log,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
