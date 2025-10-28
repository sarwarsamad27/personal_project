import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StatsView extends StatelessWidget {
  const StatsView();

  @override
  Widget build(BuildContext context) {
    final stats = [
      {
        'title': 'Total Sales',
        'value': 'Rs. 1.2M',
        'icon': LucideIcons.dollarSign,
        'gradient': [Color(0xFF4F46E5), Color(0xFF6EE7B7)],
      },
      {
        'title': 'Orders',
        'value': '345',
        'icon': LucideIcons.shoppingBag,
        'gradient': [Color(0xFFFF6A00), Color(0xFFFFD300)],
      },
      {
        'title': 'Products',
        'value': '58',
        'icon': LucideIcons.package,
        'gradient': [Color(0xFF36D1DC), Color(0xFF5B86E5)],
      },
      {
        'title': 'Selling Products',
        'value': '42',
        'icon': LucideIcons.trendingUp,
        'gradient': [Color(0xFF11998E), Color(0xFF38EF7D)],
      },
      {
        'title': 'Revenue This Month',
        'value': 'Rs. 230,000',
        'icon': LucideIcons.barChart3,
        'gradient': [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
      },
      {
        'title': 'Pending Orders',
        'value': '12',
        'icon': LucideIcons.clock,
        'gradient': [Color(0xFFFF512F), Color(0xFFF09819)],
      },
    ];

    return GridView.builder(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, i) {
        final item = stats[i];
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: List<Color>.from(item['gradient'] as List),
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
              Icon(item['icon'] as IconData, color: Colors.white, size: 24),
              Text(
                item['title'] as String,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
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
