import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';

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
  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
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
      backgroundColor: AppColor.bottomSheetColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      context: context,
      builder: (context) {
        return StatefulBuilder(
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
                        color: Colors.white24,
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
                                    ? Colors.orange
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
                                    ? Colors.orange
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
                              setSheetState(() => isVerifying = true);
                              await Future.delayed(const Duration(seconds: 2));

                              if (codeController.text.length < 4) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.redAccent
                                          .withOpacity(0.9),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          15.r,
                                        ),
                                      ),
                                      title: const Row(
                                        children: [
                                          Icon(
                                            LucideIcons.alertTriangle,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "Invalid Code",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      content: const Text(
                                        "Please enter a valid 4-digit verification code.",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text(
                                            "OK",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                setSheetState(() => isVerifying = false);
                                return;
                              }

                              Navigator.pop(context);
                              setState(() {
                                final amount =
                                    double.tryParse(amountController.text) ?? 0;
                                currentBalance -= amount;
                                transactions.insert(0, {
                                  'title':
                                      'Withdrawal Request via $selectedMethod',
                                  'amount':
                                      '- Rs. ${amount.toStringAsFixed(0)}',
                                  'icon': LucideIcons.clock,
                                  'color': Colors.yellow,
                                  'date':
                                      '${DateTime.now().day} ${_monthName(DateTime.now().month)} ${DateTime.now().year}',
                                  'status': 'pending',
                                  'details': {
                                    'productPrice': '-',
                                    'orderDate': '-',
                                    'deliveredDate': '-',
                                    'transactionDate':
                                        '${DateTime.now().toLocal()}',
                                    'method': selectedMethod,
                                  },
                                });
                              });

                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: AppColor.bottomSheetColor,
                                  title: const Text(
                                    "Request Sent",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: const Text(
                                    "Your withdrawal request has been sent and is pending confirmation.",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        "OK",
                                        style: TextStyle(color: Colors.orange),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: isVerifying
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
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
                        onPressed: () {
                          final amount = double.tryParse(amountController.text);
                          if (nameController.text.isEmpty ||
                              phoneController.text.isEmpty ||
                              amount == null ||
                              amount <= 0 ||
                              amount > currentBalance ||
                              selectedMethod == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please fill all fields correctly!",
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }
                          setSheetState(() => showCodeField = true);
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return  CustomAppContainer(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    const Text(
                      "Current Balance",
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "Rs. ${currentBalance.toStringAsFixed(0)}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      icon: const Icon(
                        LucideIcons.arrowDownCircle,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Withdraw",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: _openWithdrawDialog,
                    ),
                  ],
                ),
              );
  }
}