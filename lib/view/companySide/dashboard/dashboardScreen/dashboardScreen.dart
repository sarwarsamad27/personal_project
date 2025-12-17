import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTabBar.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  String selectedFilter = "Weekly";

  final Map<String, List<double>> chartData = {
    "Daily": [4, 6, 8, 5, 9, 3, 7],
    "Weekly": [12, 9, 15, 8, 20, 16, 11],
    "Monthly": [50, 60, 45, 80, 70, 95, 65],
  };

  final Map<String, List<String>> chartLabels = {
    "Daily": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
    "Weekly": ["W1", "W2", "W3", "W4", "W5", "W6", "W7"],
    "Monthly": ["Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct"],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      body: Stack(
        children: [
          /// ---------- Gradient Header ----------
          Container(
            height: 230.h,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              gradient: LinearGradient(
                colors: [Color(0xFFFF6A00), Color(0xFFFFD300)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// ---------- Fixed Chart Container ----------
          Positioned(
            top: 50.h,
            left: 16.w,
            right: 16.w,
            child: CustomAppContainer(
              padding: EdgeInsets.all(18.w),
              color: Colors.white,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "📊 Sales Overview",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      CustomAppContainer(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                         
                        ),

                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(20.r),

                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedFilter,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color((0xFFFF6A00)),
                            ),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            items: ["Daily", "Weekly", "Monthly"]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      e,
                                      style: const TextStyle(
                                        color: Color(0xFFFF6A00),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedFilter = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  /// Chart
                  SizedBox(
                    height: 200.h,
                    child: BarChart(
                      BarChartData(
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final labels = chartLabels[selectedFilter]!;
                                return Padding(
                                  padding: EdgeInsets.only(top: 6.h),
                                  child: Text(
                                    labels[value.toInt() % labels.length],
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: List.generate(
                          7,
                          (i) => BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: chartData[selectedFilter]![i],
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6A00),
                                    Color(0xFFFFD300),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 16.w,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 390.h),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    /// ---------- Custom Tab Bar ----------
                    CustomTabBar(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
