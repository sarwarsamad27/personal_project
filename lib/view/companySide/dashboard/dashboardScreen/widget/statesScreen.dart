import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/viewModel/providers/dashboardProvider/dashboard_provider.dart';
import 'package:provider/provider.dart';

class StatsView extends StatelessWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();

    if (provider.loading) {
      return Center(
        child: SpinKitThreeBounce(color: AppColor.primaryColor, size: 30.0),
      );
    }

    final data = provider.dashboardData?.data;
    if (data == null) return const SizedBox();

    final stats = [
      // ===== SALES =====
      {
        'title': 'Total Sales',
        'value': 'Rs. ${data.totalSales}',
        'icon': Icons.currency_ruble_sharp,
        'gradient': [Color(0xFF4F46E5), Color(0xFF6EE7B7)],
      },

      // ===== ORDERS =====
      {
        'title': 'Total Orders',
        'value': '${data.totalOrders}',
        'icon': LucideIcons.shoppingBag,
        'gradient': [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
      },
      {
        'title': 'Delivered Orders',
        'value': '${data.deliveredOrders}',
        'icon': LucideIcons.truck,
        'gradient': [Color(0xFFFF6A00), Color(0xFFFFD300)],
      },
      {
        'title': 'Pending Orders',
        'value': '${data.pendingOrders}',
        'icon': LucideIcons.clock,
        'gradient': [Color(0xFF11998E), Color(0xFF38EF7D)],
      },

      // ===== PRODUCTS =====
      {
        'title': 'Total Products',
        'value': '${data.totalProducts}',
        'icon': LucideIcons.package,
        'gradient': [Color(0xFFFF512F), Color(0xFFF09819)],
      },
      {
        'title': 'Total Quantity',
        'value': '${data.totalQuantity}',
        'icon': LucideIcons.layers,
        'gradient': [Color(0xFF36D1DC), Color(0xFF5B86E5)],
      },

      // ===== WALLET =====
      {
        'title': 'Wallet Balance',
        'value': 'Rs. ${data.wallet?.currentBalance ?? 0}',
        'icon': LucideIcons.wallet,
        'gradient': [Color(0xFF06B6D4), Color(0xFF3B82F6)],
      },
      {
        'title': 'Delivered Amount',
        'value': 'Rs. ${data.wallet?.totalDelivered ?? 0}',
        'icon': LucideIcons.checkCircle,
        'gradient': [Color(0xFF22C55E), Color(0xFF16A34A)],
      },
      {
        'title': 'Pending Withdraw',
        'value': 'Rs. ${data.wallet?.pendingWithdraw ?? 0}',
        'icon': LucideIcons.hourglass,
        'gradient': [Color(0xFF0EA5E9), Color(0xFF22D3EE)],
      },
      {
        'title': 'Completed Withdraw',
        'value': 'Rs. ${data.wallet?.completedWithdraw ?? 0}',
        'icon': LucideIcons.badgeCheck,
        'gradient': [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      },
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: stats.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14.h,
        crossAxisSpacing: 14.w,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, i) {
        final item = stats[i];
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: item['gradient'] as List<Color>,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(item['icon'] as IconData, color: Colors.white, size: 24.sp),
              Text(
                item['title'] as String,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13.sp,
                ),
              ),
              Text(
                item['value'] as String,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
