import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/viewModel/providers/chatProvider/chatThread_provider.dart';
import 'package:provider/provider.dart';

import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/view/companySide/dashboard/ChatListScreen/chatList_screen.dart';
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

  final screens = const [
    HomeDashboard(),
    CategoryScreen(),
    CompanyChatListScreen(),
    OrderScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompanyChatThreadsProvider()..fetchThreads(),
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) async {
              if (didPop) return;

              final now = DateTime.now();
              if (lastPressed == null ||
                  now.difference(lastPressed!) > const Duration(seconds: 2)) {
                lastPressed = now;
                AppToast.error("Press again to exit");
                return;
              }

              final shouldExit = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Text("Do you want to quit?"),
                  content: const Text("Are you sure you want to exit the app?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("No"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Yes"),
                    ),
                  ],
                ),
              );

              if (shouldExit == true) SystemNavigator.pop();
            },
            child: Scaffold(
              extendBody: _currentIndex == 3 || _currentIndex == 4,
              backgroundColor: const Color(0xFFF9FAFB),
              body: screens[_currentIndex],
              bottomNavigationBar: _PremiumNavBar(
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PremiumNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _PremiumNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = context.select<CompanyChatThreadsProvider, int>(
      (p) => p.unreadTotal,
    );

    final barHeight = 76.h;

    return SizedBox(
      height: barHeight + 26.h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // ✅ Base premium bar (pill)
          Container(
            height: barHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                _slot(
                  child: _NavItem(
                    icon: LucideIcons.home,
                    label: "Home",
                    selected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                ),
                _slot(
                  child: _NavItem(
                    icon: LucideIcons.package,
                    label: "Products",
                    selected: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                ),

                // ✅ center gap slot (equal width)
                _slot(child: const SizedBox.shrink()),

                _slot(
                  child: _NavItem(
                    icon: LucideIcons.receipt,
                    label: "Orders",
                    selected: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),
                ),
                _slot(
                  child: _NavItem(
                    icon: LucideIcons.user,
                    label: "Profile",
                    selected: currentIndex == 4,
                    onTap: () => onTap(4),
                  ),
                ),
              ],
            ),
          ),

          // ✅ Floating center messages button
          Positioned(
            top: -6.h,
            child: _CenterMessagesButton(
              selected: currentIndex == 2,
              unreadCount: unread,
              onTap: () => onTap(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slot({required Widget child}) {
    return Expanded(child: child);
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: selected
                ? AppColor.primaryColor.withOpacity(0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22.sp, // ✅ fixed, no jump
                color: selected ? AppColor.primaryColor : Colors.grey,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp, // ✅ fixed, no jump
                  color: selected ? AppColor.primaryColor : Colors.grey,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterMessagesButton extends StatelessWidget {
  final bool selected;
  final int unreadCount;
  final VoidCallback onTap;

  const _CenterMessagesButton({
    required this.selected,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 66.w,
        height: 66.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: selected
                ? [
                    AppColor.primaryColor,
                    AppColor.primaryColor.withOpacity(0.85),
                  ]
                : [Colors.white, Colors.white],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: selected ? Colors.transparent : Colors.black12,
            width: 1.2,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(
              LucideIcons.messageCircle,
              size: 26.sp,
              color: selected ? Colors.white : AppColor.primaryColor,
            ),

            if (unreadCount > 0)
              Positioned(
                right: -2.w,
                top: -2.w,
                child: _Badge(count: unreadCount),
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    final text = count > 99 ? "99+" : "$count";
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
