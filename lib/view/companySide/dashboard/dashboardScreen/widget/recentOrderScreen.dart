import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RecentOrdersView extends StatelessWidget {
  const RecentOrdersView();

  @override
  Widget build(BuildContext context) {
    final orders = List.generate(15, (i) {
      return {
        'orderId': '#ORD-${1200 + i}',
        'customer': 'Ali Raza',
        'amount': 'Rs. ${(4500 + (i * 700))}',
        'status': i % 2 == 0 ? 'Delivered' : 'Pending',
      };
    });

    return ListView.builder(
      itemCount: orders.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, i) {
        final order = orders[i];
        final isDelivered = order['status'] == 'Delivered';
        return Container(
          margin: EdgeInsets.only(bottom: 14.h),
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFF7F8FA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26.r,
                    backgroundColor: isDelivered
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    child: Icon(
                      LucideIcons.shoppingCart,
                      color: isDelivered
                          ? Colors.green
                          : const Color(0xFFFF6A00),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['orderId']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        order['customer']!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                order['amount']!,
                style: TextStyle(
                  color: const Color(0xFFFF6A00),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
