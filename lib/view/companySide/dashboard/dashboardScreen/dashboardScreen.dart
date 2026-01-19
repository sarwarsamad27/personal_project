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

class _HomeDashboardState extends State<HomeDashboard>
    with TickerProviderStateMixin {
  String selectedFilter = "Weekly";

  late final AnimationController _cardController;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;

  late final AnimationController _chartController;
  late final Animation<double> _chartScale;

  @override
  void initState() {
    super.initState();

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _cardFade = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    );
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic),
        );

    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _chartScale = Tween<double>(begin: 0.985, end: 1.0).animate(
      CurvedAnimation(parent: _chartController, curve: Curves.easeOutCubic),
    );

    Future.microtask(() {
      context.read<DashboardProvider>().getDashboardDataOnce();
      context.read<CompanySalesChartProvider>().getChartData(type: "weekly");
    });

    // run premium entry animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cardController.forward();
      _chartController.forward();
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  // ✅ Weekly range label ko 2 lines me split karna:
  // "22 Dec - 28 Dec" -> ["22 Dec -", "28 Dec"]
  List<String> _twoLineWeekLabel(String label) {
    final t = label.trim();
    if (!t.contains("-")) return [t, ""];

    final parts = t.split("-");
    final left = parts.first.trim();
    final right = parts.length > 1 ? parts.sublist(1).join("-").trim() : "";

    // line1: "22 Dec -"
    // line2: "28 Dec"
    return ["$left -", right];
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
            left: 3.w,
            right: 3.w,
            child: FadeTransition(
              opacity: _cardFade,
              child: SlideTransition(
                position: _cardSlide,
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

                          // ✅ Dropdown driven by Provider (no setState)
                          Selector<CompanySalesChartProvider, String>(
                            selector: (_, p) => p.selectedType,
                            builder: (context, selectedType, _) {
                              String uiValue;
                              switch (selectedType) {
                                case "daily":
                                  uiValue = "Daily";
                                  break;
                                case "monthly":
                                  uiValue = "Monthly";
                                  break;
                                default:
                                  uiValue = "Weekly";
                              }

                              return CustomAppContainer(
                                height: 40.h,
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(20.r),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: uiValue,
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
                                      if (value == null) return;

                                      // premium refresh feel on filter change
                                      _chartController.forward(from: 0);

                                      context
                                          .read<CompanySalesChartProvider>()
                                          .getChartData(
                                            type: value.toLowerCase(),
                                            // refresh: false (default) => cache use
                                          );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      /// ---------- Chart ----------
                      SizedBox(
                        height:
                            260.h, // ✅ a bit more height to avoid label overlap
                        child: ScaleTransition(
                          scale: _chartScale,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeOutCubic,
                            transitionBuilder: (child, anim) {
                              // no theme/color change; only premium fade+slide
                              final slide =
                                  Tween<Offset>(
                                    begin: const Offset(0, 0.02),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: anim,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  );
                              return FadeTransition(
                                opacity: anim,
                                child: SlideTransition(
                                  position: slide,
                                  child: child,
                                ),
                              );
                            },
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

                                final labels = chart.labels ?? [];
                                final values = chart.values ?? [];

                                final rawMax = values.isEmpty
                                    ? 0
                                    : values.reduce((a, b) => a > b ? a : b);

                                final maxValue = rawMax == 0
                                    ? 10
                                    : rawMax * 1.2;
                                final count = values.length;

                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(14.r),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14.r),
                                      border: Border.all(
                                        color: Colors.black.withOpacity(0.05),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 14,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.only(
                                      top: 8.h,
                                      left: 3.w,
                                      right: 3.w,
                                      bottom: 1.h,
                                    ),
                                    child: BarChart(
                                      BarChartData(
                                        maxY: maxValue.toDouble(),
                                        alignment:
                                            BarChartAlignment.spaceAround,
                                        groupsSpace: 10.w,
                                        barTouchData: BarTouchData(
                                          enabled: true,
                                          touchTooltipData: BarTouchTooltipData(
                                            getTooltipColor: (_) =>
                                                Colors.black87,
                                            tooltipRoundedRadius: 10.r,
                                            getTooltipItem: (group, _, rod, __) {
                                              final idx = group.x.toInt();
                                              final fullLabel =
                                                  (idx >= 0 &&
                                                      idx < labels.length)
                                                  ? labels[idx]
                                                  : "";

                                              return BarTooltipItem(
                                                "${fullLabel.isNotEmpty ? "$fullLabel\n" : ""}PKR ${rod.toY.toInt()}",
                                                TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12.sp,
                                                  height: 1.25,
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
                                              color: Colors.grey.withOpacity(
                                                0.15,
                                              ),
                                              strokeWidth: 1,
                                            );
                                          },
                                        ),
                                        borderData: FlBorderData(show: false),
                                        titlesData: FlTitlesData(
                                          leftTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                          rightTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                          topTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              interval: 1,
                                              reservedSize:
                                                  58.h, // ✅ enough for 2 lines
                                              getTitlesWidget: (value, meta) {
                                                final i = value.toInt();
                                                if (i < 0 || i >= count) {
                                                  return const SizedBox.shrink();
                                                }

                                                final full = (i < labels.length)
                                                    ? labels[i]
                                                    : "";

                                                final lines = _twoLineWeekLabel(
                                                  full,
                                                );

                                                return SideTitleWidget(
                                                  axisSide: meta.axisSide,
                                                  space: 12.h,
                                                  child: SizedBox(
                                                    width:
                                                        52.w, // per-bar width
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          lines[0],
                                                          maxLines: 1,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: 10.sp,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color:
                                                                Colors.black87,
                                                            height: 1.1,
                                                          ),
                                                        ),
                                                        SizedBox(height: 2.h),
                                                        Text(
                                                          lines[1],
                                                          maxLines: 1,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: 10.sp,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                Colors.black87,
                                                            height: 1.1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        barGroups: List.generate(
                                          count,
                                          (i) => BarChartGroupData(
                                            x: i,
                                            barRods: [
                                              BarChartRodData(
                                                toY: values[i].toDouble(),
                                                width: 14.w,
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFFFF6A00),
                                                    Color(0xFFFFD300),
                                                  ],
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                ),
                                                backDrawRodData:
                                                    BackgroundBarChartRodData(
                                                      show: true,
                                                      toY: maxValue.toDouble(),
                                                      color: Colors.grey
                                                          .withOpacity(0.08),
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
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// ---------- Stats Section ----------
          Padding(
            padding: EdgeInsets.only(top: 410.h),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    StatsView(),
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
