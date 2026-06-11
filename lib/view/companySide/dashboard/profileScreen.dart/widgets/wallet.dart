import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/widgets/jazzcash_payment_screen.dart';
import 'package:new_brand/viewModel/providers/orderProvider/getCompanyAmount_provider.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart'; // used by _openWithdrawDialog
import 'package:provider/provider.dart';

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
    final codeController = TextEditingController();
    String? selectedMethod;
    bool showCodeField = false;
    bool isVerifying = false;

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
                      SizedBox(height: 15.h),

                      CustomTextField(
                        hintText: "Enter amount to withdraw",
                        controller: amountController,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 20.h),

                      // Payment Method
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setSheetState(
                                () => selectedMethod = 'JazzCash',
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: selectedMethod == 'JazzCash'
                                      ? Colors.green
                                      : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  "JazzCash",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 15.w),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setSheetState(
                                () => selectedMethod = 'Easypaisa',
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: selectedMethod == 'Easypaisa'
                                      ? Colors.green
                                      : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  "Easypaisa",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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

                                setSheetState(() => isVerifying = false);

                                if (!verified) {
                                  AppToast.show("Invalid or expired code");
                                  return;
                                }

                                Navigator.pop(context, true);

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

                            if (nameController.text.isEmpty ||
                                phoneController.text.isEmpty ||
                                amount == null ||
                                amount <= 0 ||
                                amount >
                                    provider
                                        .currentBalance || // ✅ REAL API BALANCE
                                selectedMethod == null) {
                              AppToast.show(
                                "Insufficient wallet balance or invalid input",
                              );
                              return;
                            }

                            final success = await provider.sendWithdrawCode(
                              name: nameController.text,
                              phone: phoneController.text,
                              amount: amountController.text,
                              method: selectedMethod!,
                            );

                            if (success) {
                              AppToast.show("Verification code sent");
                              setSheetState(() => showCodeField = true);
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
    );
  }

  void _openAddMoneyDialog() {
    final amountCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      context: context,
      builder: (_) => Padding(
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

              // JazzCash header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.asset(
                      'assets/images/JazzCashLogo.jpg',
                      width: 32.r,
                      height: 32.r,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppColor.primaryColor,
                        size: 28.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Add Money via JazzCash',
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
                    borderSide: const BorderSide(
                      color: Color(0xFFCC0000),
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter amount';
                  final amt = double.tryParse(v) ?? 0;
                  if (amt < 100) return 'Minimum Rs 100';
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
                        backgroundColor: const Color(0xFFFFF0F0),
                        labelStyle: const TextStyle(
                          color: Color(0xFFCC0000),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: 20.h),

              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: CustomButton(
                  text: "Pay with JazzCash",
                  onTap: () {
                    if (!formKey.currentState!.validate()) return;
                    final amount = double.parse(amountCtrl.text.trim());
                    Navigator.pop(context); // close sheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JazzCashPaymentScreen(
                          amount: amount,
                          onPaymentDone: () {
                            if (mounted) {
                              context
                                  .read<CompanyWalletProvider>()
                                  .fetchCompanyWallet();
                            }
                          },
                        ),
                      ),
                    );
                  },
                  second: true,
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
              ],
            ),
          ),
        );
      },
    );
  }
}
