import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/view/companySide/dashboard/dashboardScreen/widget/statesScreen.dart';
import 'package:new_brand/viewModel/providers/dashboardProvider/companySaleChart_provider.dart';
import 'package:new_brand/viewModel/providers/dashboardProvider/dashboard_provider.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  String selectedFilter = "Weekly";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DashboardProvider>().getDashboardDataOnce();
      context.read<CompanySalesChartProvider>().getChartData(type: "weekly");
    });
  }

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

          /// ---------- Chart Card ----------
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
                  /// ---------- Header ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "📊 Sales Overview",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CustomAppContainer(
                        height: 40.h,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(20.r),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedFilter,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFFFF6A00),
                            ),
                            items: ["Daily", "Weekly", "Monthly"]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      e,
                                      style: const TextStyle(
                                        color: Color(0xFFFF6A00),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedFilter = value!;
                              });
                              context
                                  .read<CompanySalesChartProvider>()
                                  .getChartData(type: value!.toLowerCase());
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  /// ---------- Chart ----------
                  SizedBox(
                    height: 220.h,
                    child: Consumer<CompanySalesChartProvider>(
                      builder: (context, chartProvider, _) {
                        final chart = chartProvider.chartData?.data;

                        if (chartProvider.loading || chart == null) {
                          return Center(
                            child: SpinKitThreeBounce(
                              color: AppColor.primaryColor,
                              size: 30,
                            ),
                          );
                        }

                        final rawMax = chart.values!.isEmpty
                            ? 0
                            : chart.values!.reduce((a, b) => a > b ? a : b);

                        final maxValue = rawMax == 0 ? 10 : rawMax * 1.2;

                        return BarChart(
                          BarChartData(
                            maxY: maxValue.toDouble(),
                            alignment: BarChartAlignment.spaceAround,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (_) => Colors.black87,
                                // tooltipBgColor: Colors.black87,
                                tooltipRoundedRadius: 8.r,
                                getTooltipItem: (group, _, rod, __) {
                                  return BarTooltipItem(
                                    "PKR ${rod.toY.toInt()}",
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: maxValue == 0
                                  ? 1
                                  : maxValue / 4,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.grey.withOpacity(0.15),
                                  strokeWidth: 1,
                                );
                              },
                            ),

                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Padding(
                                      padding: EdgeInsets.only(top: 6.h),
                                      child: Text(
                                        chart.labels![value.toInt()],
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            barGroups: List.generate(
                              chart.values!.length,
                              (i) => BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: chart.values![i].toDouble(),
                                    width: 18.w,
                                    borderRadius: BorderRadius.circular(10.r),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFF6A00),
                                        Color(0xFFFFD300),
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: maxValue.toDouble(),
                                      color: Colors.grey.withOpacity(0.08),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          swapAnimationDuration: const Duration(
                            milliseconds: 600,
                          ),
                          swapAnimationCurve: Curves.easeOutCubic,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// ---------- Stats Section ----------
          Padding(
            padding: EdgeInsets.only(top: 380.h),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: const [SizedBox(height: 20), StatsView()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
