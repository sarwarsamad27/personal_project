import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaymentTabBar extends StatefulWidget {
  final Widget firstTab;
  final Widget secondTab;

  final Widget? thirdTab;

  final String firstTabbarName;
  final String secondTabbarName;

  final String? thirdTabbarName;

  final Function(int index)? onTabChanged;

  const PaymentTabBar({
    super.key,
    required this.firstTab,
    required this.secondTab,
    required this.firstTabbarName,
    required this.secondTabbarName,
    this.thirdTab,
    this.thirdTabbarName,
    this.onTabChanged,
  });

  @override
  State<PaymentTabBar> createState() => _PaymentTabBarState();
}

class _PaymentTabBarState extends State<PaymentTabBar> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

  void changeTab(int index) {
    _selectedIndex.value = index;

    if (widget.onTabChanged != null) {
      widget.onTabChanged!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      widget.firstTabbarName,
      widget.secondTabbarName,
      if (widget.thirdTab != null && widget.thirdTabbarName != null)
        widget.thirdTabbarName!,
    ];

    return ValueListenableBuilder<int>(
      valueListenable: _selectedIndex,
      builder: (context, index, child) {
        return Expanded(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: List.generate(tabs.length, (i) {
                    bool selected = index == i;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => changeTab(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            gradient: selected
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFFFF6A00),
                                      Color(0xFFFFD300),
                                    ],
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                          child: Center(
                            child: Text(
                              tabs[i],
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.black87,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              SizedBox(height: 20.h),

              /// 🔻 TAB CONTENT
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child:
                      (index == 0
                              ? widget.firstTab
                              : index == 1
                              ? widget.secondTab
                              : widget.thirdTab!)
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.05, end: 0, duration: 400.ms),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
