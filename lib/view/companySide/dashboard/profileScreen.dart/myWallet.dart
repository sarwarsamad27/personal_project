import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/widgets/wallet.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/paymentTabbar.dart';

class WalletHistoryScreen extends StatefulWidget {
  const WalletHistoryScreen({super.key});

  @override
  State<WalletHistoryScreen> createState() => _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends State<WalletHistoryScreen> {
  List<Map<String, dynamic>> transactions = [
    {
      'title': 'Order #1021 Received',
      'amount': '+ Rs. 2,500',
      'icon': LucideIcons.checkCircle,
      'color': Colors.green,
      'date': '5 Nov 2025',
      'status': 'completed',
    },
    {
      'title': 'Order #1019 Received',
      'amount': '+ Rs. 1,200',
      'icon': LucideIcons.checkCircle,
      'color': Colors.green,
      'date': '3 Nov 2025',
      'status': 'completed',
    },
  ];

  List<Map<String, dynamic>> orders = [
    {
      'orderId': '#2024',
      'status': 'Delivered',
      'date': '6 Nov 2025',
      'amount': 'Rs. 2,100',
    },
    {
      'orderId': '#2025',
      'status': 'Pending',
      'date': '8 Nov 2025',
      'amount': 'Rs. 900',
    },
    {
      'orderId': '#2026',
      'status': 'Returned',
      'date': '10 Nov 2025',
      'amount': 'Rs. 1,400',
    },
  ];

  Widget buildTransactionTab() {
    return ListView.separated(
      itemCount: transactions.length,
      separatorBuilder: (_, __) => Divider(color: Colors.white24, height: 20.h),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return Row(
          children: [
            CustomAppContainer(
              padding: EdgeInsets.all(10.w),
              child: Icon(tx['icon'], color: tx['color']),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx['title'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    tx['date'],
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  tx['amount'],
                  style: TextStyle(
                    color: tx['color'],
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  tx['status'] == 'pending' ? "Pending" : "Completed",
                  style: TextStyle(
                    color: tx['status'] == 'pending'
                        ? Colors.yellow
                        : Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget buildOrdersTab() {
    return ListView.separated(
      itemCount: orders.length,
      separatorBuilder: (_, __) => Divider(color: Colors.white24, height: 15.h),
      itemBuilder: (context, index) {
        final order = orders[index];
        Color statusColor;
        if (order['status'] == 'Delivered') {
          statusColor = Colors.green;
        } else if (order['status'] == 'Pending') {
          statusColor = Colors.yellow;
        } else {
          statusColor = Colors.red;
        }

        return CustomAppContainer(
          padding: EdgeInsets.all(12.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order ${order['orderId']}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    order['date'],
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    order['amount'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    order['status'],
                    style: TextStyle(color: statusColor, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        centerTitle: true,
        title: const Text("Wallet"),
      ),
      body: CustomBgContainer(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              Wallet(),
              SizedBox(height: 25.h),
              PaymentTabBar(
                firstTab: buildTransactionTab(),
                secondTab: buildOrdersTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
