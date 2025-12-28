// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:new_brand/view/companySide/dashboard/dashboardScreen/widget/recentOrderScreen.dart';
// import 'package:new_brand/view/companySide/dashboard/dashboardScreen/widget/statesScreen.dart';

// class CustomTabBar extends StatefulWidget {
//   @override
//   State<CustomTabBar> createState() => _CustomTabBarState();
// }

// class _CustomTabBarState extends State<CustomTabBar> {
//   int selectedIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     final tabs = ["Stats", "Recent Orders"];

//     return Column(
//       children: [
//         // 🔹 Custom tab buttons
//         Container(
//           padding: EdgeInsets.all(6.w),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(30.r),
//             boxShadow: [
//               BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
//             ],
//           ),
//           child: Row(
//             children: List.generate(tabs.length, (index) {
//               bool selected = selectedIndex == index;
//               return Expanded(
//                 child: GestureDetector(
//                   onTap: () => setState(() => selectedIndex = index),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 250),
//                     padding: EdgeInsets.symmetric(vertical: 10.h),
//                     decoration: BoxDecoration(
//                       gradient: selected
//                           ? const LinearGradient(
//                               colors: [Color(0xFFFF6A00), Color(0xFFFFD300)],
//                             )
//                           : null,
//                       borderRadius: BorderRadius.circular(25.r),
//                     ),
//                     child: Center(
//                       child: Text(
//                         tabs[index],
//                         style: TextStyle(
//                           color: selected ? Colors.white : Colors.black87,
//                           fontWeight: selected
//                               ? FontWeight.bold
//                               : FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ),

//         SizedBox(height: 20.h),

//         // 🔹 Tab content
//         AnimatedSwitcher(
//           duration: const Duration(milliseconds: 300),
//           child: selectedIndex == 0
//               ? const StatsView()
//               : const RecentOrdersView(),
//         ),
//       ],
//     );
//   }
// }
