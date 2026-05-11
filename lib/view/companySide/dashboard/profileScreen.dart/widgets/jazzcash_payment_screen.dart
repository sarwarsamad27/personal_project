import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/myWallet.dart';
import 'package:new_brand/viewModel/providers/orderProvider/getCompanyAmount_provider.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:provider/provider.dart';

import 'wallet.dart';

class JazzCashPaymentScreen extends StatefulWidget {
  final double amount;
  final VoidCallback onPaymentDone;

  const JazzCashPaymentScreen({
    super.key,
    required this.amount,
    required this.onPaymentDone,
  });

  @override
  State<JazzCashPaymentScreen> createState() => _JazzCashPaymentScreenState();
}

class _JazzCashPaymentScreenState extends State<JazzCashPaymentScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _otpSent = false;
  String? _txnRefNo;
  String? _errorMsg;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() => _errorMsg = null);
    final phone = _phoneController.text.trim();

    if (!RegExp(r'^03[0-9]{9}$').hasMatch(phone)) {
      setState(() => _errorMsg = 'Enter valid number (03XXXXXXXXX)');
      return;
    }

    final provider = context.read<CompanyWalletProvider>();
    final res = await provider.initiateJazzcashCredit(
      phone: phone,
      amount: widget.amount.toStringAsFixed(0),
    );

    if (res != null && res['txnRefNo'] != null) {
      setState(() {
        _txnRefNo = res['txnRefNo'];
        _otpSent = true;
      });
    } else {
      setState(() => _errorMsg = 'Error sending OTP. Please try again.');
    }
  }

  Future<void> _confirmPayment() async {
    setState(() => _errorMsg = null);
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      setState(() => _errorMsg = 'Enter 6 digit OTP');
      return;
    }

    final provider = context.read<CompanyWalletProvider>();
    final success = await provider.confirmJazzcashCredit(
      txnRefNo: _txnRefNo!,
      otp: otp,
      context: context,
    );

    if (success) {
      widget.onPaymentDone();
      AppToast.success(
        'Rs ${widget.amount.toStringAsFixed(0)} added to your wallet successfully!',
      );
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      setState(
        () => _errorMsg = provider.isLoading
            ? 'Please wait...'
            : 'Invalid OTP or payment failed. Try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompanyWalletProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          'JazzCash Payment',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount display
            Center(
              child: Text(
                'Rs ${widget.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFCC0000),
                ),
              ),
            ),
            SizedBox(height: 32.h),

            if (!_otpSent) ...[
              Text(
                'JazzCash Number',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '03XXXXXXXXX',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "Send OTP",
                  isLoading: provider.isLoading,
                  onTap: provider.isLoading ? null : _sendOtp,
                ),
              ),
            ] else ...[
              Text(
                'OTP sent to ${_phoneController.text.trim()}. Please enter the OTP to confirm your payment.',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey),
              ),
              SizedBox(height: 16.h),
              Text(
                'Enter OTP',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: '6 digit OTP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Confirm Payment',
                  isLoading: provider.isLoading,
                  onTap: provider.isLoading ? null : _confirmPayment,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _otpSent = false),
                child: Text(
                  'Change Number',
                  style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                ),
              ),
            ],

            if (_errorMsg != null) ...[
              SizedBox(height: 16.h),
              Text(
                _errorMsg!,
                style: TextStyle(color: Colors.red, fontSize: 13.sp),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
