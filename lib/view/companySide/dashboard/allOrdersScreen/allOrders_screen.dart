import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_brand/models/orders/allOrders_model.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/socketServices.dart';
import 'package:new_brand/resources/utiles.dart';
import 'package:new_brand/view/companySide/dashboard/allOrdersScreen/allOrderDetail_screen.dart';
import 'package:new_brand/viewModel/providers/orderProvider/getAllOrdersAnyStatus_provider.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:provider/provider.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  final ScrollController _scrollController = ScrollController();

  // Debounced live-refresh + dispose bookkeeping — same pattern as
  // dashboardScreen.dart's _setupLiveDashboardSocket. This screen shows
  // orders across every status, all of which can change from buyer/courier/
  // admin actions elsewhere while it's open.
  Timer? _liveRefreshDebounce;
  void Function(dynamic)? _onNewOrder;
  void Function(dynamic)? _onOrderStatusUpdated;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<GetAllOrdersAnyStatusProvider>().fetchOrders(
        refresh: true,
      );
    });
    _scrollController.addListener(() {
      final provider = context.read<GetAllOrdersAnyStatusProvider>();
      if (!_scrollController.hasClients) return;
      final position = _scrollController.position;
      if (position.pixels >= position.maxScrollExtent - 200 &&
          !provider.isLoading &&
          provider.hasMore) {
        provider.fetchOrders();
      }
    });
    _setupLiveSocket();
  }

  Future<void> _setupLiveSocket() async {
    final token = await LocalStorage.getToken() ?? "";
    if (token.isEmpty || !mounted) return;
    final socket = await SocketService().ensureConnected(
      baseUrl: Global.imageUrl,
      token: token,
    );
    if (socket == null || !mounted) return;

    _onNewOrder = (_) => _scheduleLiveRefresh();
    _onOrderStatusUpdated = (_) => _scheduleLiveRefresh();
    socket.on("new_order", _onNewOrder!);
    socket.on("order_status_updated", _onOrderStatusUpdated!);
  }

  void _scheduleLiveRefresh() {
    _liveRefreshDebounce?.cancel();
    _liveRefreshDebounce = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      context.read<GetAllOrdersAnyStatusProvider>().fetchOrders(refresh: true);
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
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final provider = context.read<GetAllOrdersAnyStatusProvider>();
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: provider.dateRange,
      helpText: "Filter orders by date",
    );
    if (picked == null) return;
    provider.applyDateRange(picked);
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'Pending':
        // Not Colors.orange — this badge sits on CustomBgContainer's orange
        // gradient background and would blend into it.
        return Colors.indigo;
      case 'Dispatched':
        return Colors.blue;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      case 'Returned':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String? status) {
    switch (status) {
      case 'Pending':
        return Icons.hourglass_empty_rounded;
      case 'Dispatched':
        return Icons.local_shipping_outlined;
      case 'Delivered':
        return Icons.check_circle_outline_rounded;
      case 'Cancelled':
        return Icons.cancel_outlined;
      case 'Returned':
        return Icons.assignment_return_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return "N/A";
    try {
      final date = DateTime.parse(isoDate).toLocal();
      const months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
      ];
      int hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final period = date.hour >= 12 ? "PM" : "AM";
      final minute = date.minute.toString().padLeft(2, '0');
      return "${date.day} ${months[date.month - 1]}, $hour:$minute $period";
    } catch (_) {
      return "N/A";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBgContainer(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        "All Orders",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Selector<GetAllOrdersAnyStatusProvider, DateTimeRange?>(
                      selector: (_, p) => p.dateRange,
                      builder: (context, range, _) {
                        return GestureDetector(
                          onTap: _pickDateRange,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                  color: Colors.white,
                                  size: 15.sp,
                                ),
                                if (range != null) ...[
                                  SizedBox(width: 6.w),
                                  Text(
                                    "${range.start.day}/${range.start.month} - ${range.end.day}/${range.end.month}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  GestureDetector(
                                    onTap: () => context
                                        .read<GetAllOrdersAnyStatusProvider>()
                                        .clearDateRange(),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 14.sp,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: Consumer<GetAllOrdersAnyStatusProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading && provider.orders.isEmpty) {
                        return const Center(
                          child: SpinKitThreeBounce(
                            color: AppColor.whiteColor,
                            size: 30,
                          ),
                        );
                      }

                      if (provider.orders.isEmpty) {
                        return _buildEmptyState();
                      }

                      return RefreshIndicator(
                        color: Colors.white,
                        backgroundColor: AppColor.primaryColor,
                        onRefresh: () => provider.fetchOrders(refresh: true),
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: EdgeInsets.only(bottom: 30.h),
                          itemCount:
                              provider.orders.length +
                              (provider.hasMore ? 1 : 0),
                          separatorBuilder: (_, __) => SizedBox(height: 14.h),
                          itemBuilder: (context, index) {
                            if (index == provider.orders.length) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                child: const Center(
                                  child: SpinKitThreeBounce(
                                    color: AppColor.whiteColor,
                                    size: 24,
                                  ),
                                ),
                              );
                            }
                            return _buildOrderCard(provider.orders[index]);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(AllOrderItem order) {
    final products = order.products ?? [];
    final firstProduct = products.isNotEmpty ? products.first : null;
    final statusColor = _statusColor(order.status);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AllOrderDetailScreen(order: order)),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.18),
              Colors.white.withValues(alpha: 0.06),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    "#${order.orderId ?? ''}",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 9.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _statusIcon(order.status),
                        color: statusColor,
                        size: 11.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        order.status ?? "Unknown",
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 70.h,
                  width: 64.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11.r),
                    child:
                        (firstProduct?.images != null &&
                            firstProduct!.images!.isNotEmpty)
                        ? Image.network(
                            Global.getImageUrl(firstProduct.images!.first),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.white38,
                              size: 22.sp,
                            ),
                          )
                        : Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.white38,
                            size: 22.sp,
                          ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstProduct?.name ?? "Product",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            color: Colors.white.withValues(alpha: 0.5),
                            size: 13.sp,
                          ),
                          SizedBox(width: 5.w),
                          Flexible(
                            child: Text(
                              order.buyerDetails?.name ?? "Customer",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 6.h,
                        children: [
                          _chip(
                            // Not AppColor.primaryColor — same orange as
                            // CustomBgContainer's background, unreadable
                            // against it.
                            label: _formatDate(order.createdAt),
                            color: Colors.white,
                            icon: Icons.calendar_month_rounded,
                          ),
                          _chip(
                            label: Utils.paymentLabel(
                              order.paymentMethod,
                              order.paymentStatus,
                            ),
                            color: Utils.paymentColor(order.paymentStatus),
                            icon: Utils.paymentIcon(order.paymentStatus),
                          ),
                          if (order.exchangeRequest != null)
                            _chip(
                              label:
                                  "Exchange: ${order.exchangeRequest!.status ?? ''}",
                              color: Colors.deepPurple,
                              icon: Icons.swap_horiz_rounded,
                            ),
                          if (order.refundRequest != null)
                            _chip(
                              label:
                                  "Refund: ${order.refundRequest!.status ?? ''}",
                              color: Colors.teal,
                              icon: Icons.currency_exchange_rounded,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${products.length} item${products.length != 1 ? 's' : ''}",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 11.sp,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      // Not AppColor.primaryColor — same orange as the page
                      // background. Dimmer white keeps it visually
                      // secondary to the bold total beside it.
                      "Rs. ",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "${order.productsTotal}",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: color.withValues(alpha: 0.7), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11.sp),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: 100.h),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: Colors.white.withValues(alpha: 0.4),
                  size: 44.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "No Orders Found",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Orders will appear here",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
