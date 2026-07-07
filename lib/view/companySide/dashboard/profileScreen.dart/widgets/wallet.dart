import 'dart:async';
import 'dart:developer';

// 💤 Firebase Phone Auth is not the active OTP provider (see backend's
// utiles/twilioVerify.js — currently Veevo Tech SMS). Kept commented for a
// future re-enable rather than deleted.
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/pakistaniBanks.dart';
import 'package:new_brand/resources/toast.dart';
// import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/widgets/firebasePhoneAuthTestScreen.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/widgets/safepay_payment_screen.dart';
import 'package:new_brand/viewModel/providers/orderProvider/getCompanyAmount_provider.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart'; // used by _openWithdrawDialog
import 'package:provider/provider.dart';

// 💤 Maps Firebase Phone Auth's error codes to messages a seller can
// actually act on. Unused while Firebase Phone Auth isn't the active
// provider — kept for when it's re-enabled.
// String firebaseAuthErrorMessage(FirebaseAuthException e) {
//   switch (e.code) {
//     case 'invalid-phone-number':
//       return 'Invalid phone number. Please check and try again.';
//     case 'too-many-requests':
//     case 'quota-exceeded':
//       return 'Too many attempts. Please try again later.';
//     case 'invalid-verification-code':
//       return 'Invalid code. Please check and try again.';
//     case 'invalid-verification-id':
//     case 'session-expired':
//       return 'Verification session expired. Please request a new code.';
//     case 'network-request-failed':
//       return 'Network error. Please check your connection.';
//     case 'user-disabled':
//       return 'This account has been disabled. Contact support.';
//     case 'operation-not-allowed':
//       return 'Phone verification is not enabled. Contact support.';
//     case 'app-not-authorized':
//     case 'missing-client-identifier':
//       return 'App verification failed. Please try again or contact support.';
//     default:
//       return e.message ?? 'Verification failed. Please try again.';
//   }
// }

class Wallet extends StatefulWidget {
  Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  double currentBalance = 12450;
  List<Map<String, dynamic>> transactions = [
    {
      'title': 'Order #1021 Received',
      'amount': '+ Rs. 2,500',
      'icon': LucideIcons.checkCircle,
      'color': Colors.green,
      'date': '5 Nov 2025',
      'status': 'completed',
      'details': {
        'productPrice': 'Rs. 2,500',
        'orderDate': '2 Nov 2025, 2:15 PM',
        'deliveredDate': '5 Nov 2025, 6:30 PM',
        'transactionDate': '5 Nov 2025, 6:45 PM',
        'method': 'Internal Wallet Transfer',
      },
    },
    {
      'title': 'Order #1019 Received',
      'amount': '+ Rs. 1,200',
      'icon': LucideIcons.checkCircle,
      'color': Colors.green,
      'date': '3 Nov 2025',
      'status': 'completed',
      'details': {
        'productPrice': 'Rs. 1,200',
        'orderDate': '1 Nov 2025, 12:45 PM',
        'deliveredDate': '3 Nov 2025, 5:10 PM',
        'transactionDate': '3 Nov 2025, 5:30 PM',
        'method': 'Internal Wallet Transfer',
      },
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyWalletProvider>().fetchCompanyWallet();
    });
  }

  void _openWithdrawDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final amountController = TextEditingController();
    final accountNumberController = TextEditingController();
    final ibanController = TextEditingController();
    final codeController = TextEditingController();
    String? selectedMethod = 'JazzCash';
    String? selectedBank;
    bool showCodeField = false;
    bool isVerifying = false;
    Timer? otpClipboardTimer;
    // The bottom sheet's StatefulBuilder can be gone by the time the
    // clipboard timer fires — every setSheetState call below is guarded by
    // this to avoid setState-after-dispose.
    bool sheetDisposed = false;

    // No SMS Retriever/autofill wired up on this screen, so instead: once
    // the user copies the code from their messaging app and returns here,
    // this poll picks it up from the clipboard and fills the field for
    // them — they still tap Verify themselves.
    void startOtpClipboardWatch(void Function(void Function()) setSheetState) {
      otpClipboardTimer?.cancel();
      otpClipboardTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
        if (sheetDisposed) return;
        final clip = await Clipboard.getData('text/plain');
        if (sheetDisposed) return;
        final match = RegExp(r'\b\d{6}\b').firstMatch(clip?.text?.trim() ?? '');
        final code = match?.group(0);
        if (code != null && code != codeController.text) {
          setSheetState(() => codeController.text = code);
        }
      });
    }

    // 💤 Firebase Phone Auth version (restore once the Blaze billing plan is
    // enabled — see wallet.dart's git history / the note in
    // CompanyWalletProvider.verifyWithdrawCode for what else needs to flip
    // back). Was: completeWithdrawal(credential, provider, setSheetState)
    // signs in with Firebase, gets an ID token, and sends that to the
    // backend instead of a raw OTP; startFirebasePhoneVerification(phone,
    // provider, setSheetState) calls FirebaseAuth.verifyPhoneNumber to
    // trigger the real SMS send and wires up its callbacks (auto-complete
    // on Android SMS retrieval, error mapping via firebaseAuthErrorMessage,
    // showCodeField=true + clipboard watch on codeSent).

    Widget methodButton(
      String label,
      String value,
      void Function(void Function()) setSheetState,
    ) {
      final isSelected = selectedMethod == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => setSheetState(() => selectedMethod = value),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
      );
    }

    showModalBottomSheet(
      backgroundColor: AppColor.appimagecolor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              final isBank = selectedMethod == 'Bank Account';

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  20.h,
                  20.w,
                  MediaQuery.of(context).viewInsets.bottom + 30.h,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 5,
                        width: 60,
                        decoration: BoxDecoration(
                          color: AppColor.whiteColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Withdraw Funds",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 25.h),

                      // Payment Method — chosen first, since the fields below
                      // depend on which one is selected.
                      Row(
                        children: [
                          methodButton('JazzCash', 'JazzCash', setSheetState),
                          SizedBox(width: 10.w),
                          methodButton('Easypaisa', 'Easypaisa', setSheetState),
                          SizedBox(width: 10.w),
                          methodButton(
                            'Bank Account',
                            'Bank Account',
                            setSheetState,
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      if (isBank) ...[
                        DropdownButtonFormField<String>(
                          initialValue: selectedBank,
                          isExpanded: true,
                          dropdownColor: AppColor.appimagecolor,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Select bank",
                            hintStyle: const TextStyle(color: Colors.white60),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 14.h,
                            ),
                          ),
                          items: kPakistaniBanks
                              .map(
                                (b) =>
                                    DropdownMenuItem(value: b, child: Text(b)),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setSheetState(() => selectedBank = v),
                        ),
                        SizedBox(height: 15.h),
                        CustomTextField(
                          hintText: "Account holder name",
                          controller: nameController,
                          keyboardType: TextInputType.name,
                        ),
                        SizedBox(height: 15.h),
                        CustomTextField(
                          hintText: "Account number",
                          controller: accountNumberController,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 15.h),
                        CustomTextField(
                          hintText: "IBAN",
                          controller: ibanController,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "Enter at least one of Account Number or IBAN",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11.sp,
                          ),
                        ),
                      ] else ...[
                        CustomTextField(
                          hintText: "Enter full name",
                          controller: nameController,
                          keyboardType: TextInputType.name,
                        ),
                        SizedBox(height: 15.h),
                        CustomTextField(
                          hintText: "Enter mobile number",
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                      SizedBox(height: 15.h),

                      CustomTextField(
                        hintText: "Enter amount to withdraw (min Rs 300)",
                        controller: amountController,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 25.h),

                      if (showCodeField)
                        Column(
                          children: [
                            CustomTextField(
                              hintText: "Enter verification code",
                              controller: codeController,
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 20.h),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 14.h,
                                  horizontal: 40.w,
                                ),
                              ),
                              onPressed: () async {
                                final provider = context
                                    .read<CompanyWalletProvider>();

                                if (codeController.text.length < 4) {
                                  AppToast.show("Invalid verification code");
                                  return;
                                }

                                setSheetState(() => isVerifying = true);

                                final verified = await provider
                                    .verifyWithdrawCode(
                                      code: codeController.text,
                                      context: context,
                                    );

                                if (sheetDisposed) return;
                                setSheetState(() => isVerifying = false);

                                if (!verified) {
                                  AppToast.show("Invalid or expired code");
                                  return;
                                }

                                otpClipboardTimer?.cancel();
                                AppToast.show("Withdrawal request submitted");
                                Navigator.pop(context, true);
                              },

                              child: isVerifying
                                  ? SpinKitThreeBounce(
                                      color: AppColor.whiteColor,
                                      size: 30.0,
                                    )
                                  : const Text(
                                      "Verify & Send Request",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ],
                        )
                      else
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 14.h,
                              horizontal: 40.w,
                            ),
                          ),
                          onPressed: () async {
                            final provider = context
                                .read<CompanyWalletProvider>();

                            final amount = double.tryParse(
                              amountController.text,
                            );

                            if (selectedMethod == null ||
                                nameController.text.isEmpty ||
                                amount == null ||
                                amount <= 0) {
                              AppToast.show("Please fill all fields correctly");
                              return;
                            }

                            if (isBank) {
                              if (selectedBank == null ||
                                  (accountNumberController.text.isEmpty &&
                                      ibanController.text.isEmpty)) {
                                AppToast.show(
                                  "Select a bank and enter account number or IBAN",
                                );
                                return;
                              }
                            } else if (phoneController.text.isEmpty) {
                              AppToast.show("Please fill all fields correctly");
                              return;
                            }

                            if (amount < 300) {
                              AppToast.show("Minimum withdrawal is Rs 300");
                              return;
                            }

                            if (amount > provider.currentBalance) {
                              AppToast.show("Insufficient wallet balance");
                              return;
                            }

                            final success = await provider.sendWithdrawCode(
                              name: nameController.text,
                              phone: phoneController.text,
                              amount: amountController.text,
                              method: isBank ? 'bank' : selectedMethod!,
                              bankName: isBank ? selectedBank : null,
                              accountNumber: isBank
                                  ? accountNumberController.text
                                  : null,
                              iban: isBank ? ibanController.text : null,
                            );

                            if (success) {
                              AppToast.show("Verification code sent");
                              setSheetState(() => showCodeField = true);
                              startOtpClipboardWatch(setSheetState);
                            } else {
                              AppToast.show("Failed to send verification code");
                            }
                          },

                          child: const Text(
                            "Confirm Withdrawal",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      sheetDisposed = true;
      otpClipboardTimer?.cancel();
    });
  }

  void _openAddMoneyDialog() {
    final amountCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    // Resolved via this State's own stable context — the bottom sheet's
    // inner Consumer<CompanyWalletProvider> context gets deactivated once
    // the sheet is popped, so onPaymentDone (which fires later, after the
    // payment screen confirms) must not re-resolve the provider from it.
    final walletProvider = context.read<CompanyWalletProvider>();

    showModalBottomSheet(
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20.w,
          14.h,
          20.w,
          MediaQuery.of(context).viewInsets.bottom + 24.h,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: 16.h),

              // Safepay header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: AppColor.primaryColor,
                    size: 28.sp,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Add Money via Safepay',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Amount field
              TextFormField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'Amount (Rs)',
                  prefixText: 'Rs  ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: AppColor.primaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter amount';
                  final amt = double.tryParse(v) ?? 0;
                  if (amt < 500) return 'Minimum Rs 500';
                  if (amt > 50000) return 'Maximum Rs 50,000';
                  return null;
                },
              ),
              SizedBox(height: 8.h),
              // Quick amounts
              Wrap(
                spacing: 8.w,
                children: [500, 1000, 2000, 5000]
                    .map(
                      (a) => ActionChip(
                        label: Text('Rs $a'),
                        onPressed: () => amountCtrl.text = '$a',
                        backgroundColor: AppColor.primaryColor.withValues(
                          alpha: 0.08,
                        ),
                        labelStyle: TextStyle(
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: 20.h),

              Consumer<CompanyWalletProvider>(
                builder: (context, provider, _) => SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: CustomButton(
                    text: "Continue to Payment",
                    isLoading: provider.isLoading,
                    onTap: provider.isLoading
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            final amount = double.parse(amountCtrl.text.trim());

                            final checkout = await provider.initSafepayCheckout(
                              amount: amount.toStringAsFixed(0),
                            );

                            if (!context.mounted) return;
                            if (checkout == null) {
                              AppToast.show(
                                'Could not start payment. Try again.',
                              );
                              return;
                            }

                            Navigator.pop(context); // close sheet
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SafepayPaymentScreen(
                                  amount: amount,
                                  checkoutUrl: checkout['url'] as String,
                                  trackId: checkout['trackId'] as String,
                                  onPaymentDone: () {
                                    walletProvider.fetchCompanyWallet();
                                  },
                                ),
                              ),
                            );
                          },
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CompanyWalletProvider>(
      builder: (context, walletProvider, _) {
        log(
          'Current Balance: ${walletProvider.currentBalance.toStringAsFixed(0)}',
        );
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: CustomAppContainer(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                const Text(
                  "Current Balance",
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 5.h),

                /// 🔥 API BALANCE HERE
                walletProvider.isLoading
                    ? SpinKitThreeBounce(color: Colors.white, size: 30)
                    : Text(
                        "Rs. ${walletProvider.currentBalance.toStringAsFixed(0)}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                SizedBox(height: 15.h),

                if (walletProvider.isOrderBlocked) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: const Color(0xFFFCA5A5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFB91C1C),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            "Pending amount: Rs. ${walletProvider.pendingDueAmount.toStringAsFixed(0)}. "
                            "Add Rs. 500 to your wallet to continue taking orders.",
                            style: TextStyle(
                              color: const Color(0xFFB91C1C),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.h),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        icon: const Icon(
                          LucideIcons.arrowDownCircle,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          "Withdraw",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () => _openWithdrawDialog(),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        icon: const Icon(
                          LucideIcons.plusCircle,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          "Add Money",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () => _openAddMoneyDialog(),
                      ),
                    ),
                  ],
                ),
                // 💤 TEST/EXPLORATION ONLY — Firebase Phone Auth isn't the
                // active OTP provider, not wired into the real withdrawal
                // flow. Kept commented (not deleted) alongside the import
                // above for a future re-enable.
                // TextButton(
                //   onPressed: () => Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (_) => const FirebasePhoneAuthTestScreen(),
                //     ),
                //   ),
                //   child: const Text(
                //     "🧪 Test Firebase Phone Auth",
                //     style: TextStyle(color: Colors.white70, fontSize: 12),
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
