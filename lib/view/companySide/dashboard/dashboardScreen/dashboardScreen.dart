import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/socketServices.dart';
import 'package:new_brand/view/companySide/dashboard/dashboardScreen/widget/statesScreen.dart';
import 'package:new_brand/view/companySide/dashboard/notificationScreen/company_notification_screen.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/widgets/sellerAnnouncementCarousel.dart';
import 'package:new_brand/viewModel/providers/dashboardProvider/companySaleChart_provider.dart';
import 'package:new_brand/viewModel/providers/dashboardProvider/dashboard_provider.dart';
import 'package:new_brand/viewModel/providers/notificationProvider/company_notification_provider.dart';
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
  // ValueNotifier instead of a plain field + setState: toggling bar/line
  // only needs to rebuild the small toggle chip and the chart widget
  // itself, not this whole (very large) dashboard build() — the chart's
  // surrounding tree (gradient header, animations, stats list, etc.)
  // would otherwise re-run on every tap for no reason.
  final ValueNotifier<bool> _showLineChart = ValueNotifier<bool>(false);

  late final AnimationController _cardController;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;

  late final AnimationController _chartController;
  late final Animation<double> _chartScale;

  // Horizontal scroll for the chart plot itself (bar/line share this) — the
  // chart opens scrolled to the newest (rightmost) point, like a price
  // chart, and the seller scrolls left for older history.
  final ScrollController _chartScrollController = ScrollController();
  // Guards the auto-scroll-to-end so it only fires when the underlying data
  // actually changes (new type/range/point-count) — not on every rebuild,
  // e.g. toggling bar/line shouldn't yank the seller back to the end if
  // they've scrolled to look at older history.
  String? _lastAutoScrolledSignature;

  void _scrollChartToEndIfNeeded(String signature) {
    if (signature == _lastAutoScrolledSignature) return;
    _lastAutoScrolledSignature = signature;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chartScrollController.hasClients) return;
      _chartScrollController.jumpTo(
        _chartScrollController.position.maxScrollExtent,
      );
    });
  }

  // Wider spacing for weekly/monthly (two-line date labels) than daily
  // (short single labels, and often many more points).
  double _perPointWidthFor(String type) {
    switch (type) {
      case "daily":
        return 36.w;
      case "monthly":
        return 48.w;
      default:
        return 54.w;
    }
  }

  // Debounced live-refresh: several socket events (new order, status
  // change, product edit) can land within the same tick, so this coalesces
  // them into a single dashboard re-fetch instead of hammering the API.
  Timer? _liveRefreshDebounce;

  // Kept so dispose() can remove exactly these callbacks — socket.off with
  // no handler would wipe out every other screen's listener for the same
  // broadcast event (e.g. order_status_updated is also heard by
  // orderScreen.dart).
  void Function(dynamic)? _onNewOrder;
  void Function(dynamic)? _onOrderStatusUpdated;
  void Function(dynamic)? _onProductUpdate;
  void Function(dynamic)? _onProductDelete;
  void Function(dynamic)? _onWithdrawNew;
  void Function(dynamic)? _onWithdrawStatus;

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
      if (!mounted) return;
      context.read<DashboardProvider>().getDashboardDataOnce();
      context.read<CompanySalesChartProvider>().getChartData(type: "weekly");
      context.read<CompanyNotificationProvider>().fetchNotifications();
    });

    _setupLiveDashboardSocket();

    // run premium entry animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cardController.forward();
      _chartController.forward();
    });
  }

  // Live-updates the stat cards whenever something that changes them
  // happens elsewhere — a new order, a status change, a product edit/delete
  // — instead of the seller having to pull-to-refresh. The seller room
  // (`seller:<profileId>`) is auto-joined server-side on socket connect
  // (see socketIndex.js), so no explicit join call is needed here.
  Future<void> _setupLiveDashboardSocket() async {
    final token = await LocalStorage.getToken() ?? "";
    if (token.isEmpty || !mounted) return;
    final socket = await SocketService().ensureConnected(
      baseUrl: Global.imageUrl,
      token: token,
    );
    if (socket == null || !mounted) return;

    _onNewOrder = (_) => _scheduleLiveDashboardRefresh();
    _onOrderStatusUpdated = (_) => _scheduleLiveDashboardRefresh();
    _onProductUpdate = (_) => _scheduleLiveDashboardRefresh();
    _onProductDelete = (_) => _scheduleLiveDashboardRefresh();
    // A withdrawal was submitted, or admin approved/rejected one — the
    // Pending/Completed Withdraw cards need the same debounced re-fetch.
    _onWithdrawNew = (_) => _scheduleLiveDashboardRefresh();
    _onWithdrawStatus = (_) => _scheduleLiveDashboardRefresh();

    socket.on("new_order", _onNewOrder!);
    socket.on("order_status_updated", _onOrderStatusUpdated!);
    socket.on("product:update", _onProductUpdate!);
    socket.on("product:delete", _onProductDelete!);
    socket.on("wallet:withdraw_new", _onWithdrawNew!);
    socket.on("wallet:withdraw_status", _onWithdrawStatus!);
  }

  void _scheduleLiveDashboardRefresh() {
    _liveRefreshDebounce?.cancel();
    _liveRefreshDebounce = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      context.read<DashboardProvider>().getDashboardDataOnce(refresh: true);
    });
  }

  @override
  void dispose() {
    _liveRefreshDebounce?.cancel();
    final socket = SocketService().socket;
    if (_onNewOrder != null) socket?.off("new_order", _onNewOrder);
    if (_onOrderStatusUpdated != null) {
      socket?.off("order_status_updated", _onOrderStatusUpdated);
    }
    if (_onProductUpdate != null) {
      socket?.off("product:update", _onProductUpdate);
    }
    if (_onProductDelete != null) {
      socket?.off("product:delete", _onProductDelete);
    }
    if (_onWithdrawNew != null) {
      socket?.off("wallet:withdraw_new", _onWithdrawNew);
    }
    if (_onWithdrawStatus != null) {
      socket?.off("wallet:withdraw_status", _onWithdrawStatus);
    }
    _cardController.dispose();
    _chartController.dispose();
    _chartScrollController.dispose();
    _showLineChart.dispose();
    super.dispose();
  }

  // ✅ Pull-to-refresh handler
  Future<void> _onRefresh() async {
    _cardController.forward(from: 0);
    _chartController.forward(from: 0);

    final chartProvider = context.read<CompanySalesChartProvider>();
    await Future.wait([
      // refresh: true — without it, getDashboardDataOnce() is a no-op
      // once the first load has already happened (see its own
      // `if (_fetched && !refresh) return;` guard), so pull-to-refresh
      // was silently doing nothing for the stat cards.
      context.read<DashboardProvider>().getDashboardDataOnce(refresh: true),
      chartProvider.getChartData(type: chartProvider.selectedType),
    ]);
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

  Future<void> _pickCustomRange(BuildContext context) async {
    final chartProvider = context.read<CompanySalesChartProvider>();
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: chartProvider.customRange,
      helpText: "Select a custom date range",
    );
    if (picked == null) return;

    _chartController.forward(from: 0);
    chartProvider.getChartData(type: chartProvider.selectedType, range: picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF3F4F8),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColor.primaryColor,
        backgroundColor: Colors.white,
        displacement: 80,
        child: Stack(
          children: [
            /// ---------- Scrollable background (needed for RefreshIndicator to trigger) ----------
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: SizedBox(height: MediaQuery.of(context).size.height),
            ),

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
              left: 6.w,
              right: 6.w,
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
                            Row(
                              children: [
                                Text(
                                  "📊 Sales Overview",
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                _NotificationBell(),
                              ],
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                  ),
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(20.r),
                                  borderColor: AppColor.appimagecolor,
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
                        SizedBox(height: 12.h),

                        /// ---------- Chart type toggle + custom date range ----------
                        Row(
                          children: [
                            ValueListenableBuilder<bool>(
                              valueListenable: _showLineChart,
                              builder: (context, showLine, _) =>
                                  _ChartTypeToggle(
                                showLine: showLine,
                                onChanged: (v) => _showLineChart.value = v,
                              ),
                            ),
                            const Spacer(),
                            Selector<CompanySalesChartProvider, DateTimeRange?>(
                              selector: (_, p) => p.customRange,
                              builder: (context, range, _) {
                                if (range == null) {
                                  return GestureDetector(
                                    onTap: () => _pickCustomRange(context),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 8.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF2FF),
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.date_range_rounded,
                                        size: 18.sp,
                                        color: const Color(0xFFFF6A00),
                                      ),
                                    ),
                                  );
                                }

                                String fmt(DateTime d) =>
                                    "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}";
                                return GestureDetector(
                                  onTap: () => _pickCustomRange(context),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(
                                        color: AppColor.appimagecolor,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.date_range_rounded,
                                          size: 14.sp,
                                          color: const Color(0xFFFF6A00),
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          "${fmt(range.start)} - ${fmt(range.end)}",
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFFFF6A00),
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        GestureDetector(
                                          onTap: () {
                                            _chartController.forward(from: 0);
                                            context
                                                .read<
                                                  CompanySalesChartProvider
                                                >()
                                                .getChartData(
                                                  type: context
                                                      .read<
                                                        CompanySalesChartProvider
                                                      >()
                                                      .selectedType,
                                                  refresh: true,
                                                );
                                          },
                                          child: Icon(
                                            Icons.close_rounded,
                                            size: 14.sp,
                                            color: const Color(0xFFFF6A00),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),

                        /// ---------- Chart ----------
                        SizedBox(
                          height: 260
                              .h, // ✅ a bit more height to avoid label overlap
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

                                  final labels = chart.labels ?? <String?>[];
                                  final rawValues = chart.values ?? <int?>[];
                                  const minChartPoints = 7;
                                  final paddedLabels = List<String?>.from(labels);
                                  final paddedValues = List<int?>.from(rawValues);

                                  while (paddedLabels.length < minChartPoints) {
                                    paddedLabels.add(null);
                                  }
                                  while (paddedValues.length < minChartPoints) {
                                    paddedValues.add(null);
                                  }

                                  final count = paddedValues.length;

                                  _scrollChartToEndIfNeeded(
                                    '${chartProvider.selectedType}-${chartProvider.customRange}-$count',
                                  );

                                  final realValues = paddedValues.whereType<int>();
                                  final rawMax = realValues.isEmpty
                                      ? 0
                                      : realValues.reduce(
                                          (a, b) => a > b ? a : b,
                                        );
                                  final maxValue = rawMax == 0
                                      ? 10
                                      : rawMax * 1.2;

                                  // A `null` label marks an unfilled
                                  // placeholder slot ("no date assigned") —
                                  // a custom range shorter than 7 periods.
                                  bool isEmptySlot(int i) =>
                                      i >= paddedLabels.length ||
                                      paddedLabels[i] == null;
                                  double valueAt(int i) =>
                                      (i < paddedValues.length
                                              ? paddedValues[i]
                                              : null)
                                          ?.toDouble() ??
                                      0;

                                  // Keep each label narrower than its
                                  // point's own column so neighbouring
                                  // labels don't crowd each other when many
                                  // points are packed in (daily especially).
                                  final labelWidth =
                                      _perPointWidthFor(chartProvider.selectedType) -
                                      8.w;

                                  Widget bottomTitle(
                                    double value,
                                    TitleMeta meta,
                                  ) {
                                    final i = value.toInt();
                                    if (i < 0 || i >= count) {
                                      return const SizedBox.shrink();
                                    }

                                    if (isEmptySlot(i)) {
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        space: 12.h,
                                        child: SizedBox(
                                          width: labelWidth,
                                          child: Text(
                                            "—",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black26,
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    // Daily: day number packed tight on
                                    // every point (matches the point
                                    // spacing), with "Mon YY" surfaced only
                                    // where the month/year actually changes
                                    // — repeating it on every single day
                                    // over a long scrollable history would
                                    // just be noise, and the transition
                                    // label needs more room than a single
                                    // point's column to stay readable.
                                    if (chartProvider.selectedType ==
                                        "daily") {
                                      final full = paddedLabels[i] ?? "";
                                      final parts = full.split(' ');
                                      final day = parts.isNotEmpty ? parts[0] : full;
                                      final monthYear = parts.length >= 3
                                          ? '${parts[1]} ${parts[2]}'
                                          : '';

                                      final prevLabel = i > 0 ? (paddedLabels[i - 1] ?? "") : "";
                                      final prevParts = prevLabel.split(' ');
                                      final prevMonthYear = prevParts.length >= 3
                                          ? '${prevParts[1]} ${prevParts[2]}'
                                          : '';
                                      final showMonthYear =
                                          i == 0 || monthYear != prevMonthYear;

                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        space: 12.h,
                                        child: SizedBox(
                                          width: 60.w,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                day,
                                                maxLines: 1,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black87,
                                                  height: 1.1,
                                                ),
                                              ),
                                              if (showMonthYear) ...[
                                                SizedBox(height: 2.h),
                                                Text(
                                                  monthYear,
                                                  maxLines: 1,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 9.sp,
                                                    fontWeight:
                                                        FontWeight.w800,
                                                    color:
                                                        AppColor.primaryColor,
                                                    height: 1.1,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    final full = paddedLabels[i] ?? "";
                                    final lines = _twoLineWeekLabel(full);

                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      space: 12.h,
                                      child: SizedBox(
                                        width: labelWidth,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              lines[0],
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87,
                                                height: 1.1,
                                              ),
                                            ),
                                            SizedBox(height: 2.h),
                                            Text(
                                              lines[1],
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                                height: 1.1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  final titlesData = FlTitlesData(
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
                                        interval: 1,
                                        reservedSize: 58.h,
                                        getTitlesWidget: bottomTitle,
                                      ),
                                    ),
                                  );

                                  final gridData = FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: maxValue == 0
                                        ? 1
                                        : maxValue / 4,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                      color: Colors.grey.withValues(alpha: 0.15),
                                      strokeWidth: 1,
                                    ),
                                  );

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14.r),
                                      border: Border.all(
                                        color: Colors.black.withValues(alpha: 0.05),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.04),
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
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final perPoint = _perPointWidthFor(
                                          chartProvider.selectedType,
                                        );
                                        // Points sit at their natural width
                                        // only once there are enough of them
                                        // to need horizontal scrolling;
                                        // otherwise stretch to fill the card
                                        // so a short range (e.g. Daily's
                                        // default week) doesn't leave dead
                                        // space on the right.
                                        final naturalWidth = perPoint * count;
                                        final chartWidth =
                                            naturalWidth < constraints.maxWidth
                                            ? constraints.maxWidth
                                            : naturalWidth;
                                        return SingleChildScrollView(
                                          controller: _chartScrollController,
                                          scrollDirection: Axis.horizontal,
                                          physics: const BouncingScrollPhysics(),
                                          child: SizedBox(
                                            width: chartWidth,
                                            // Only this chart widget swaps
                                            // on bar/line toggle — everything
                                            // above (header, dropdown, date
                                            // range chip) stays untouched.
                                            child: ValueListenableBuilder<bool>(
                                              valueListenable: _showLineChart,
                                              builder: (context, showLine, _) =>
                                                  showLine
                                        ? LineChart(
                                            LineChartData(
                                              maxY: maxValue.toDouble(),
                                              minY: 0,
                                              gridData: gridData,
                                              borderData: FlBorderData(
                                                show: false,
                                              ),
                                              titlesData: titlesData,
                                              lineTouchData: LineTouchData(
                                                enabled: true,
                                                touchTooltipData: LineTouchTooltipData(
                                                  getTooltipColor: (_) =>
                                                      Colors.black87,
                                                  tooltipRoundedRadius: 10.r,
                                                  fitInsideHorizontally: true,
                                                  fitInsideVertically: true,
                                                  getTooltipItems: (spots) =>
                                                      spots.map((s) {
                                                        final idx = s.x.toInt();
                                                        if (isEmptySlot(idx)) {
                                                          return LineTooltipItem(
                                                            "No date selected",
                                                            TextStyle(
                                                              color: Colors
                                                                  .white70,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 12.sp,
                                                            ),
                                                          );
                                                        }
                                                        return LineTooltipItem(
                                                          "${paddedLabels[idx] ?? ''}\nPKR ${s.y.toInt()}",
                                                          TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 12.sp,
                                                            height: 1.25,
                                                          ),
                                                        );
                                                      }).toList(),
                                                ),
                                              ),
                                              lineBarsData: [
                                                LineChartBarData(
                                                  // Only the leading real
                                                  // (non-empty) run —
                                                  // trailing empty slots are
                                                  // simply not plotted,
                                                  // leaving a visible gap
                                                  // rather than a misleading
                                                  // zero.
                                                  spots: [
                                                    for (
                                                      int i = 0;
                                                      i < count &&
                                                          !isEmptySlot(i);
                                                      i++
                                                    )
                                                      FlSpot(
                                                        i.toDouble(),
                                                        valueAt(i),
                                                      ),
                                                  ],
                                                  isCurved: true,
                                                  gradient:
                                                      const LinearGradient(
                                                        colors: [
                                                          Color(0xFFFF6A00),
                                                          Color(0xFFFFD300),
                                                        ],
                                                      ),
                                                  barWidth: 3,
                                                  dotData: const FlDotData(
                                                    show: true,
                                                  ),
                                                  belowBarData: BarAreaData(
                                                    show: true,
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        const Color(
                                                          0xFFFF6A00,
                                                        ).withValues(alpha: 0.18),
                                                        const Color(
                                                          0xFFFFD300,
                                                        ).withValues(alpha: 0.02),
                                                      ],
                                                      begin:
                                                          Alignment.topCenter,
                                                      end: Alignment
                                                          .bottomCenter,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            duration: const Duration(
                                              milliseconds: 600,
                                            ),
                                            curve: Curves.easeOutCubic,
                                          )
                                        : BarChart(
                                            BarChartData(
                                              maxY: maxValue.toDouble(),
                                              alignment:
                                                  BarChartAlignment.spaceBetween,
                                              groupsSpace: 6.w,
                                              barTouchData: BarTouchData(
                                                enabled: true,
                                                touchTooltipData: BarTouchTooltipData(
                                                  getTooltipColor: (_) =>
                                                      Colors.black87,
                                                  tooltipRoundedRadius: 10.r,
                                                  fitInsideHorizontally: true,
                                                  fitInsideVertically: true,
                                                  getTooltipItem:
                                                      (group, _, rod, __) {
                                                        final idx = group.x
                                                            .toInt();
                                                        if (isEmptySlot(idx)) {
                                                          return BarTooltipItem(
                                                            "No date selected",
                                                            TextStyle(
                                                              color: Colors
                                                                  .white70,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 12.sp,
                                                            ),
                                                          );
                                                        }
                                                        final fullLabel =
                                                            paddedLabels[idx] ?? "";
                                                        return BarTooltipItem(
                                                          "${fullLabel.isNotEmpty ? "$fullLabel\n" : ""}PKR ${rod.toY.toInt()}",
                                                          TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 12.sp,
                                                            height: 1.25,
                                                          ),
                                                        );
                                                      },
                                                ),
                                              ),
                                              gridData: gridData,
                                              borderData: FlBorderData(
                                                show: false,
                                              ),
                                              titlesData: titlesData,
                                              barGroups: List.generate(count, (
                                                i,
                                              ) {
                                                final empty = isEmptySlot(i);
                                                return BarChartGroupData(
                                                  x: i,
                                                  barRods: [
                                                    BarChartRodData(
                                                      toY: empty
                                                          ? maxValue * 0.04
                                                          : valueAt(i),
                                                      width: 14.w,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10.r,
                                                          ),
                                                      color: empty
                                                          ? Colors.grey
                                                                .withValues(
                                                                  alpha: 0.25,
                                                                )
                                                          : null,
                                                      gradient: empty
                                                          ? null
                                                          : const LinearGradient(
                                                              colors: [
                                                                Color(
                                                                  0xFFFF6A00,
                                                                ),
                                                                Color(
                                                                  0xFFFFD300,
                                                                ),
                                                              ],
                                                              begin: Alignment
                                                                  .bottomCenter,
                                                              end: Alignment
                                                                  .topCenter,
                                                            ),
                                                      backDrawRodData:
                                                          BackgroundBarChartRodData(
                                                            show: true,
                                                            toY: maxValue
                                                                .toDouble(),
                                                            color: Colors.grey
                                                                .withValues(
                                                                  alpha: 0.08,
                                                                ),
                                                          ),
                                                    ),
                                                  ],
                                                );
                                              }),
                                            ),
                                            swapAnimationDuration:
                                                const Duration(
                                                  milliseconds: 600,
                                                ),
                                            swapAnimationCurve:
                                                Curves.easeOutCubic,
                                          ),
                                            ),
                                          ),
                                        );
                                      },
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
              padding: EdgeInsets.only(top: 450.h),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      const SellerAnnouncementCarousel(),
                      SizedBox(height: 20.h),
                      StatsView(),
                      // Extra clearance so the last row of cards scrolls
                      // fully clear of the bottom nav's floating messages
                      // button (extendBody:true in CompanyHomeScreen paints
                      // that bar on top of this content, not behind it).
                      SizedBox(height: MediaQuery.of(context).padding.bottom),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final unread = context.select<CompanyNotificationProvider, int>(
      (p) => p.unreadCount,
    );

    return GestureDetector(
      onTap: () {
        // Mark all read instantly on tap (fire & forget)
        context.read<CompanyNotificationProvider>().markAllRead();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CompanyNotificationScreen()),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: 36.w,
            height: 36.w,
            child: Lottie.asset(
              'assets/gif/notification_icon.json',
              repeat: true,
              fit: BoxFit.contain,
            ),
          ),
          if (unread > 0)
            Positioned(
              right: -4.w,
              top: -4.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  unread > 99 ? '99+' : '$unread',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Bar / Line chart-type toggle ──────────────────────────────────────────
class _ChartTypeToggle extends StatelessWidget {
  final bool showLine;
  final ValueChanged<bool> onChanged;
  const _ChartTypeToggle({required this.showLine, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget option(IconData icon, bool isLine) {
      final selected = showLine == isLine;
      return GestureDetector(
        onTap: () => onChanged(isLine),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFF6A00) : Colors.transparent,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(
            icon,
            size: 16.sp,
            color: selected ? Colors.white : Colors.grey[500],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          option(Icons.bar_chart_rounded, false),
          option(Icons.show_chart_rounded, true),
        ],
      ),
    );
  }
}
