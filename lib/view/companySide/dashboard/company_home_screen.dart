import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/view/companySide/dashboard/dashboardScreen/dashboardScreen.dart';
import 'package:new_brand/view/companySide/dashboard/orderScreen/orderScreen.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategoryScreen.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/profileScreen.dart';
import 'package:new_brand/view/companySide/dashboard/reportScreen/reportScreen.dart';

class CompanyHomeScreen extends StatefulWidget {
  const CompanyHomeScreen({super.key});

  @override
  State<CompanyHomeScreen> createState() => _CompanyHomeScreenState();
}

class _CompanyHomeScreenState extends State<CompanyHomeScreen> {
  int _currentIndex = 0;

  final screens = [
    const HomeDashboard(),
    const CategoryScreen(),
    const OrderScreen(),
    const ReportScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: screens[_currentIndex],

          /// 🔹 Animated Bottom Navbar
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                navItem(LucideIcons.home, "Home", 0),
                navItem(LucideIcons.package, "Products", 1),
                navItem(LucideIcons.receipt, "Orders", 2),
                navItem(LucideIcons.barChart, "Reports", 3),
                navItem(LucideIcons.user, "Profile", 4),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 🔸 Custom Navbar Item
  Widget navItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: isSelected ? AppColor.primaryColor : Colors.grey,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isSelected ? AppColor.primaryColor : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
