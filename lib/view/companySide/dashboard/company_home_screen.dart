import 'dart:io'; // ✅ Needed for exit(0)
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/view/companySide/dashboard/dashboardScreen/dashboardScreen.dart';
import 'package:new_brand/view/companySide/dashboard/orderScreen/orderScreen.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/productCategoryScreen.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/profileScreen.dart';

class CompanyHomeScreen extends StatefulWidget {
  const CompanyHomeScreen({super.key});

  @override
  State<CompanyHomeScreen> createState() => _CompanyHomeScreenState();
}

class _CompanyHomeScreenState extends State<CompanyHomeScreen> {
  int _currentIndex = 0;
  DateTime? lastPressed;

  final screens = [
    const HomeDashboard(),
    const CategoryScreen(),
    const OrderScreen(),
    const ProfileScreen(),
  ];

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();

    if (lastPressed == null ||
        now.difference(lastPressed!) > const Duration(seconds: 2)) {
      lastPressed = now;
      AppToast.error("Press again to exit");
      return false;
    }

    bool exitApp =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Do you want to quit?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text("Yes"),
              ),
            ],
          ),
        ) ??
        false;

    if (exitApp) {
      exit(0);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
        return WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            extendBody: _currentIndex == 3
                ? true
                : _currentIndex == 2
                ? true
                : false,
            backgroundColor: const Color(0xFFF9FAFB),
            body: screens[_currentIndex],
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
                  navItem(LucideIcons.user, "Profile", 3),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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
