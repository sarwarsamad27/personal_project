import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/view/companySide/dashboard/allOrdersScreen/allOrders_screen.dart';
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
    if (data == null) return Center(child: const Text("No data found"));

    final stats = [
      // ===== SALES =====
      {
        'title': 'Total Sales',
        'value': 'Rs. ${data.totalSales}',
        'icon': Icons.currency_ruble_sharp,
        'gradient': [const Color(0xFF4F46E5), const Color(0xFF6EE7B7)],
      },

      // ===== ORDERS =====
      {
        'title': 'Total Orders',
        'value': '${data.totalOrders}',
        'icon': LucideIcons.shopping_bag,
        'gradient': [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AllOrdersScreen()),
        ),
      },
      {
        'title': 'Delivered Orders',
        'value': '${data.deliveredOrders}',
        'icon': LucideIcons.truck,
        'gradient': [const Color(0xFFFF6A00), const Color(0xFFFFD300)],
      },
      {
        'title': 'Pending Orders',
        'value': '${data.pendingOrders}',
        'icon': LucideIcons.clock,
        'gradient': [const Color(0xFF11998E), const Color(0xFF38EF7D)],
      },

      // ===== PRODUCTS =====
      {
        'title': 'Total Products',
        'value': '${data.totalProducts}',
        'icon': LucideIcons.package,
        'gradient': [const Color(0xFFFF512F), const Color(0xFFF09819)],
      },
      {
        'title': 'Low Stock Products',
        'value': '${data.lowStockProducts ?? 0}',
        'icon': LucideIcons.triangle_alert,
        'gradient': [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      },
      {
        'title': 'Out of Stock Products',
        'value': '${data.outOfStockProducts ?? 0}',
        'icon': LucideIcons.octagon_alert,
        'gradient': [const Color(0xFFEF4444), const Color(0xFFB91C1C)],
      },

      // ===== WALLET =====
      {
        'title': 'Wallet Balance',
        'value': 'Rs. ${data.wallet?.currentBalance ?? 0}',
        'icon': LucideIcons.wallet,
        'gradient': [const Color(0xFF06B6D4), const Color(0xFF3B82F6)],
      },
      {
        'title': 'Delivered Amount',
        'value': 'Rs. ${data.wallet?.totalDelivered ?? 0}',
        'icon': LucideIcons.circle_check,
        'gradient': [const Color(0xFF22C55E), const Color(0xFF16A34A)],
      },
      {
        'title': 'Pending Withdraw',
        'value': 'Rs. ${data.wallet?.pendingWithdraw ?? 0}',
        'icon': LucideIcons.hourglass,
        'gradient': [const Color(0xFF0EA5E9), const Color(0xFF22D3EE)],
      },
      {
        'title': 'Completed Withdraw',
        'value': 'Rs. ${data.wallet?.completedWithdraw ?? 0}',
        'icon': LucideIcons.badge_check,
        'gradient': [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
      },
    ];

    // A plain 2-column GridView leaves a lone last card stranded on the
    // left with dead space beside it whenever the count is odd (11 cards
    // here). Pairing rows manually lets that leftover card span the full
    // width instead — in a wider "summary bar" layout, not just a stretched
    // small card — so it reads as an intentional highlight, not a mistake.
    final rows = <Widget>[];
    for (int i = 0; i < stats.length; i += 2) {
      final isLastOdd = i == stats.length - 1;
      rows.add(
        isLastOdd
            ? _buildWideCard(stats[i], i)
            : Row(
                children: [
                  Expanded(child: _buildCard(stats[i], i)),
                  SizedBox(width: 14.w),
                  Expanded(child: _buildCard(stats[i + 1], i + 1)),
                ],
              ),
      );
      if (i + 2 < stats.length) rows.add(SizedBox(height: 14.h));
    }

    return Column(children: rows);
  }

  Widget _buildCard(Map<String, dynamic> item, int index) {
    final onTap = item['onTap'] as VoidCallback?;
    final card = Container(
      padding: EdgeInsets.all(16.w),
      height: 118.h,
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

    return _animated(onTap != null ? GestureDetector(onTap: onTap, child: card) : card, index);
  }

  // Full-width variant for a lone trailing card — icon in a circular bubble
  // beside the title/value instead of stacked, so the extra width reads as
  // a deliberate summary row rather than an oversized version of the
  // 2-column card.
  Widget _buildWideCard(Map<String, dynamic> item, int index) {
    final onTap = item['onTap'] as VoidCallback?;
    final card = Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(item['icon'] as IconData, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] as String,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item['value'] as String,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 19.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return _animated(onTap != null ? GestureDetector(onTap: onTap, child: card) : card, index);
  }

  Widget _animated(Widget child, int index) {
    return child
        .animate()
        .fadeIn(duration: 400.ms, delay: (index * 50).ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }
}
