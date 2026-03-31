import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/viewModel/providers/orderProvider/getCompanyAmount_provider.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';
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

                                Navigator.pop(context , true);

                                AppToast.show("Withdrawal request submitted");
                                 Navigator.pop(context , true);
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
    final phoneController = TextEditingController();
    final amountController = TextEditingController();
    bool isInitiating = false;
    bool isVerifying = false;
    String? currentTxnRef;

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
                        "Add Money (JazzCash)",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 25.h),

                      if (currentTxnRef == null) ...[
                        CustomTextField(
                          hintText: "Enter JazzCash number (03XXXXXXXXX)",
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 15.h),
                        CustomTextField(
                          hintText: "Enter amount to add (Min Rs. 100)",
                          controller: amountController,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 25.h),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: Size(double.infinity, 50.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: isInitiating ? null : () async {
                            final provider = context.read<CompanyWalletProvider>();
                            final amount = amountController.text.trim();
                            final phone = phoneController.text.trim();

                            if (phone.length != 11 || !phone.startsWith("03")) {
                              AppToast.show("Please enter a valid 11-digit JazzCash number");
                              return;
                            }

                            if (amount.isEmpty || double.parse(amount) < 100) {
                              AppToast.show("Minimum amount is Rs. 100");
                              return;
                            }

                            setSheetState(() => isInitiating = true);
                            final result = await provider.initiateJazzcashCredit(
                              phone: phone,
                              amount: amount,
                            );
                            setSheetState(() => isInitiating = false);

                            if (result != null) {
                              setSheetState(() => currentTxnRef = result['txnRefNo']);
                              AppToast.show(result['message'] ?? "Please check your phone for the PIN prompt");
                            }
                          },
                          child: isInitiating 
                            ? SpinKitThreeBounce(color: Colors.white, size: 20)
                            : const Text("Pay with JazzCash", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ] else ...[
                        Icon(LucideIcons.smartphone, color: Colors.green, size: 50.sp),
                        SizedBox(height: 20.h),
                        Text(
                          "A PIN prompt has been sent to your phone number ${phoneController.text}.",
                          style: TextStyle(color: Colors.white, fontSize: 14.sp),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "Please enter your JazzCash PIN on your phone and then click the button below.",
                          style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30.h),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            minimumSize: Size(double.infinity, 50.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: isVerifying ? null : () async {
                            setSheetState(() => isVerifying = true);
                            final success = await context.read<CompanyWalletProvider>().confirmJazzcashCredit(
                              txnRefNo: currentTxnRef!,
                              context: context,
                            );
                            setSheetState(() => isVerifying = false);

                            if (success) {
                              Navigator.pop(context);
                              AppToast.show("Payment Successful! Wallet Credited.");
                            }
                          },
                          child: isVerifying
                            ? SpinKitThreeBounce(color: Colors.white, size: 20)
                            : const Text("I Have Entered My PIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        TextButton(
                          onPressed: () => setSheetState(() => currentTxnRef = null),
                          child: const Text("Cancel & Go Back", style: TextStyle(color: Colors.white60)),
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    
    return Consumer<CompanyWalletProvider>(
      
      builder: (context, walletProvider, _) {
        log('Current Balance: ${walletProvider.currentBalance.toStringAsFixed(0)}');
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        icon: const Icon(LucideIcons.plusCircle, color: Colors.white, size: 18),
                        label: const Text("Deposit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        onPressed: () => _openAddMoneyDialog(),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        icon: const Icon(LucideIcons.arrowDownCircle, color: Colors.white, size: 18),
                        label: const Text("Withdraw", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        onPressed: () => _openWithdrawDialog(),
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
    
  }}
