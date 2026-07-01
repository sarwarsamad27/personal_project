import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/resources/socketServices.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/view/companySide/dashboard/orderScreen/leopards_tracking_screen.dart';
import 'package:new_brand/view/companySide/dashboard/orderScreen/orderDetailScreen.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/productDetail/productDetailScreen.dart';
import 'package:new_brand/viewModel/providers/orderProvider/getCancelledOrders_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/getDispatchedorder_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/order_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/pendingToCancel_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/pendingToDispatched_provider.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/paymentTabbar.dart';
import 'package:provider/provider.dart';
import 'package:new_brand/models/orders/getMyOrders_model.dart';
import 'package:new_brand/widgets/customBgContainer.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Set<String> _processingOrders = {};

  // ── Bulk selection state ──
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};
  bool _bulkDispatching = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<GetMyOrdersProvider>(context, listen: false).fetchOrders();
    });
    _setupSocket();
    _scrollController.addListener(() {
      final provider = Provider.of<GetMyOrdersProvider>(context, listen: false);
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !provider.loading &&
          !provider.loadMore) {
        provider.fetchOrders(isLoadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setupSocket() async {
    final token = await LocalStorage.getToken() ?? "";
    if (token.isEmpty) return;
    final socket = await SocketService().ensureConnected(
      baseUrl: Global.imageUrl,
      token: token,
    );
    socket?.on("order_status_updated", (data) {
      if (!mounted) return;
      if (data != null && data['orderId'] != null) {
        final String orderId = data['orderId'];
        final String status = data['status'];
        final ordersProvider = Provider.of<GetMyOrdersProvider>(
          context,
          listen: false,
        );
        ordersProvider.updateOrderInList(orderId, status: status);
        if (status == 'Dispatched') {
          Provider.of<GetDispatchedOrderProvider>(
            context,
            listen: false,
          ).fetchDispatchedOrders(isRefresh: true);
        } else if (status == 'Cancelled') {
          // Prepend to cancelled tab from socket data
          try {
            final rawOrder = data['order'];
            if (rawOrder != null) {
              final order = Orders.fromJson(
                Map<String, dynamic>.from(rawOrder as Map),
              );
              Provider.of<GetCancelledOrdersProvider>(
                context,
                listen: false,
              ).prependFromSocket(order);
            }
          } catch (_) {}
        }
      }
    });

    // ── New order arrives: add instantly without refresh ─────────────────
    socket?.on("new_order", (data) {
      if (!mounted || data == null) return;
      try {
        final order = Orders.fromJson(Map<String, dynamic>.from(data as Map));
        Provider.of<GetMyOrdersProvider>(
          context,
          listen: false,
        ).addNewOrder(order);
        AppToast.success(
          "New Order: ${order.orderId ?? ''} — Rs ${order.grandTotal ?? 0}",
        );
      } catch (_) {}
    });
  }

  // ── Bulk selection helpers ────────────────────────────────────────────────

  void _enterSelectionMode(String id) {
    setState(() {
      _selectionMode = true;
      _selectedIds.add(id);
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _selectAll(List pendingList) {
    setState(() {
      if (_selectedIds.length == pendingList.length) {
        _selectedIds.clear();
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        for (final o in pendingList) {
          _selectedIds.add(o.sId as String);
        }
      }
    });
  }

  Future<void> _bulkDispatch() async {
    if (_selectedIds.isEmpty || _bulkDispatching) return;

    setState(() => _bulkDispatching = true);

    // Capture providers before any await
    final dispatchProvider = Provider.of<PendingToDispatchedProvider>(
      context,
      listen: false,
    );
    final ordersProvider = Provider.of<GetMyOrdersProvider>(
      context,
      listen: false,
    );
    final dispatchedProvider = Provider.of<GetDispatchedOrderProvider>(
      context,
      listen: false,
    );

    int success = 0;
    int failed = 0;

    for (final id in List<String>.from(_selectedIds)) {
      final ok = await dispatchProvider.updateOrderStatus(
        orderId: id,
        status: "dispatched",
      );
      if (ok) {
        success++;
        ordersProvider.updateOrderInList(id, status: "Dispatched");
      } else {
        failed++;
      }
    }

    await dispatchedProvider.fetchDispatchedOrders(isRefresh: true);

    if (!mounted) return;
    setState(() {
      _bulkDispatching = false;
      _selectionMode = false;
      _selectedIds.clear();
    });

    if (success > 0) AppToast.success("$success order(s) dispatched");
    if (failed > 0) AppToast.error("$failed order(s) failed");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBgContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 50.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer3<
                GetMyOrdersProvider,
                GetDispatchedOrderProvider,
                GetCancelledOrdersProvider
              >(
                builder:
                    (
                      context,
                      pendingProvider,
                      dispatchedProvider,
                      cancelledProvider,
                      _,
                    ) {
                      return PaymentTabBar(
                        onTabChanged: (index) {
                          if (index == 0) {
                            Provider.of<GetMyOrdersProvider>(
                              context,
                              listen: false,
                            ).fetchOrders(isRefresh: true);
                          } else if (index == 1) {
                            Provider.of<GetDispatchedOrderProvider>(
                              context,
                              listen: false,
                            ).fetchDispatchedOrders(isRefresh: true);
                          } else {
                            Provider.of<GetCancelledOrdersProvider>(
                              context,
                              listen: false,
                            ).fetchCancelledOrders(isRefresh: true);
                          }
                        },
                        firstTab: pendingTab(pendingProvider),
                        secondTab: dispatchedTab(dispatchedProvider),
                        thirdTab: cancelledTab(cancelledProvider),
                        firstTabbarName: "Pending",
                        secondTabbarName: "Dispatched",
                        thirdTabbarName: "Cancelled",
                      );
                    },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget pendingTab(GetMyOrdersProvider provider) {
    final list = (provider.orderModel?.orders ?? [])
        .where((e) => e.status == "Pending")
        .toList();

    final Widget listWidget = _buildOrderList(
      list: list,
      isPendingTab: true,
      pendingProvider: provider,
      isApiLoading: provider.loading,
      scrollController: _scrollController,
    );

    if (list.isEmpty) return listWidget;

    // Wrap with Stack so bottom action bar floats above the list
    return Stack(
      children: [
        listWidget,
        // ── Selection Header (top) ──
        if (_selectionMode)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Text(
                    "${_selectedIds.length} selected",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _selectAll(list),
                    child: Text(
                      _selectedIds.length == list.length
                          ? "Deselect All"
                          : "Select All",
                      style: TextStyle(
                        color: AppColor.primaryColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  GestureDetector(
                    onTap: _cancelSelection,
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                      size: 18.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ── Bottom Bulk Dispatch Bar ──
        if (_selectionMode)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xff2A1A0E),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Cancel
                  GestureDetector(
                    onTap: _cancelSelection,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  // Dispatch button
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectedIds.isEmpty || _bulkDispatching
                          ? null
                          : _bulkDispatch,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        decoration: BoxDecoration(
                          color: _selectedIds.isEmpty
                              ? Colors.white.withValues(alpha: 0.12)
                              : AppColor.primaryColor,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: _selectedIds.isNotEmpty
                              ? [
                                  BoxShadow(
                                    color: AppColor.primaryColor.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: _bulkDispatching
                              ? SpinKitThreeBounce(
                                  color: Colors.white,
                                  size: 18.sp,
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.local_shipping_rounded,
                                      color: Colors.white,
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      _selectedIds.isEmpty
                                          ? "Select orders"
                                          : "Dispatch ${_selectedIds.length}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
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
      ],
    );
  }

  Widget dispatchedTab(GetDispatchedOrderProvider provider) {
    final list = (provider.dispatchedModel?.orders ?? [])
        .where((e) => e.status == "Dispatched")
        .toList();
    return _buildOrderList(
      list: list,
      isPendingTab: false,
      pendingProvider: null,
      isApiLoading: provider.loading,
      scrollController: null,
    );
  }

  Widget cancelledTab(GetCancelledOrdersProvider provider) {
    if (provider.loading && provider.orders.isEmpty) {
      return const Center(
        child: SpinKitThreeBounce(color: AppColor.whiteColor, size: 30),
      );
    }

    final list = provider.orders;

    if (list.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: 80.h),
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
                    Icons.cancel_outlined,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 44.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  "No Cancelled Orders",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Cancelled orders will appear here",
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

    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: AppColor.primaryColor,
      onRefresh: () => provider.fetchCancelledOrders(isRefresh: true),
      child: ListView.separated(
        padding: EdgeInsets.only(top: 4.h, bottom: 60.h),
        itemCount: list.length,
        separatorBuilder: (_, __) => SizedBox(height: 14.h),
        itemBuilder: (context, index) {
          final order = list[index];
          final products = (order.products ?? []);
          final firstProduct = products.isNotEmpty ? products.first : null;
          final isByBuyer = order.cancelledBy == 'buyer';

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.35),
                width: 1.2,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red.withValues(alpha: 0.12),
                  Colors.red.withValues(alpha: 0.04),
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
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order ID + Cancelled by badge
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
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isByBuyer
                                  ? Icons.person_outline_rounded
                                  : Icons.store_outlined,
                              color: Colors.redAccent,
                              size: 10.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              isByBuyer
                                  ? "Cancelled by Customer"
                                  : "Cancelled by Seller",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Product row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductImage(firstProduct),
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
                            _buildInfoRow(
                              icon: Icons.person_outline_rounded,
                              label: order.buyerDetails?.name ?? "Customer",
                            ),
                            SizedBox(height: 4.h),
                            _buildInfoRow(
                              icon: Icons.inventory_2_outlined,
                              label:
                                  "${products.length} Item${products.length != 1 ? 's' : ''}",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Cancel reason
                  if (order.cancelReason != null &&
                      order.cancelReason!.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Colors.white.withValues(alpha: 0.4),
                            size: 13.sp,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              "Reason: ${order.cancelReason}",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 11.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 12.h),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Amount",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 10.sp,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Rs.",
                                style: TextStyle(
                                  color: AppColor.primaryColor,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                "${order.grandTotal ?? 0}",
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
                      if (firstProduct != null)
                        _buildActionButton(
                          label: "Product",
                          icon: Icons.visibility_outlined,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(
                                productId: firstProduct.productId,
                                categoryId: firstProduct.categoryId,
                              ),
                            ),
                          ),
                          outlined: true,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderList({
    required List list,
    required bool isPendingTab,
    GetMyOrdersProvider? pendingProvider,
    bool isApiLoading = false,
    ScrollController? scrollController,
  }) {
    if (isApiLoading && list.isEmpty) {
      return const Center(
        child: SpinKitThreeBounce(color: AppColor.whiteColor, size: 30),
      );
    }

    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: AppColor.primaryColor,
      onRefresh: () async {
        if (isPendingTab && pendingProvider != null) {
          await pendingProvider.fetchOrders(isRefresh: true);
        } else {
          await Provider.of<GetDispatchedOrderProvider>(
            context,
            listen: false,
          ).fetchDispatchedOrders(isRefresh: true);
        }
      },
      child: list.isEmpty
          ? _buildEmptyState(isPendingTab)
          : ListView.separated(
              padding: EdgeInsets.only(
                top: _selectionMode && isPendingTab ? 58.h : 4.h,
                bottom: _selectionMode && isPendingTab ? 100.h : 60.h,
              ),
              controller: scrollController,
              itemCount:
                  list.length + ((pendingProvider?.loadMore ?? false) ? 1 : 0),
              separatorBuilder: (_, __) => SizedBox(height: 14.h),
              itemBuilder: (context, index) {
                if (index == list.length &&
                    (pendingProvider?.loadMore ?? false)) {
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
                final dynamic order = list[index];
                final List<dynamic> products = (order.products ?? []);
                final dynamic firstProduct = products.isNotEmpty
                    ? products.first
                    : null;
                final bool isStale =
                    isPendingTab && _isStaleOrder(order.createdAt as String?);
                final String orderId = order.sId as String? ?? '';
                final bool isSelected = _selectedIds.contains(orderId);

                return _buildOrderCard(
                  order: order,
                  products: products,
                  firstProduct: firstProduct,
                  isStale: isStale,
                  isPendingTab: isPendingTab,
                  orderId: orderId,
                  isSelected: isSelected,
                );
              },
            ),
    );
  }

  Widget _buildOrderCard({
    required dynamic order,
    required List<dynamic> products,
    required dynamic firstProduct,
    required bool isStale,
    required bool isPendingTab,
    String orderId = '',
    bool isSelected = false,
  }) {
    final bool inSelectMode = _selectionMode && isPendingTab;

    return GestureDetector(
      onLongPress: isPendingTab && !_selectionMode
          ? () => _enterSelectionMode(orderId)
          : null,
      onTap: inSelectMode ? () => _toggleSelection(orderId) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? AppColor.primaryColor
                : isStale
                ? Colors.red.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.25),
            width: isSelected ? 2 : 1.2,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    AppColor.primaryColor.withValues(alpha: 0.22),
                    AppColor.primaryColor.withValues(alpha: 0.08),
                  ]
                : isStale
                ? [
                    Colors.red.withValues(alpha: 0.18),
                    Colors.red.withValues(alpha: 0.06),
                  ]
                : [
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
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: _buildOrderCardContent(
                  order: order,
                  products: products,
                  firstProduct: firstProduct,
                  isStale: isStale,
                  isPendingTab: isPendingTab,
                  inSelectMode: inSelectMode,
                ),
              ),
            ),
            // ── Selection checkbox overlay ──
            if (inSelectMode)
              Positioned(
                top: 10.h,
                right: 10.w,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColor.primaryColor
                        : Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColor.primaryColor
                          : Colors.white.withValues(alpha: 0.6),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14.sp,
                        )
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCardContent({
    required dynamic order,
    required List<dynamic> products,
    required dynamic firstProduct,
    required bool isStale,
    required bool isPendingTab,
    required bool inSelectMode,
  }) {
    return AbsorbPointer(
      absorbing: inSelectMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildOrderCardChildren(
          order: order,
          products: products,
          firstProduct: firstProduct,
          isStale: isStale,
          isPendingTab: isPendingTab,
          inSelectMode: inSelectMode,
        ),
      ),
    );
  }

  // The actual card content (extracted so GestureDetector wraps correctly)
  List<Widget> _buildOrderCardChildren({
    required dynamic order,
    required List<dynamic> products,
    required dynamic firstProduct,
    required bool isStale,
    required bool isPendingTab,
    required bool inSelectMode,
  }) {
    return [
      // ── Top Row: Image + Info ──
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          _buildProductImage(firstProduct),
          SizedBox(width: 14.w),

          // Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID + Stale Badge
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
                    if (isStale) ...[
                      SizedBox(width: 6.w),
                      _buildBadge(
                        label: "48h+",
                        bgColor: Colors.red,
                        textColor: Colors.white,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),

                // Product Name + Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        firstProduct?.name ?? "Product",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    if (isPendingTab)
                      _buildPendingStatusDropdown(orderId: order.sId)
                    else
                      _buildBadge(
                        label: "Dispatched",
                        bgColor: Colors.green,
                        textColor: Colors.white,
                        icon: Icons.local_shipping_outlined,
                      ),
                  ],
                ),

                SizedBox(height: 10.h),

                // Customer Row
                _buildInfoRow(
                  icon: Icons.person_outline_rounded,
                  label: order.buyerDetails?.name ?? "Customer",
                ),
                SizedBox(height: 5.h),

                // Items Row
                _buildInfoRow(
                  icon: Icons.inventory_2_outlined,
                  label:
                      "${products.length} Item${products.length != 1 ? 's' : ''}",
                ),

                // Tracking number — dispatched orders only
                if (!isPendingTab &&
                    order.trackNumber != null &&
                    (order.trackNumber as String).isNotEmpty) ...[
                  SizedBox(height: 5.h),
                  _buildInfoRow(
                    icon: Icons.local_shipping_outlined,
                    label: "Track #: ${order.trackNumber}",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LeopardsTrackingScreen(
                          trackNumber: order.trackNumber as String,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),

      SizedBox(height: 14.h),

      // ── Divider ──
      Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.white.withValues(alpha: 0.2),
              Colors.transparent,
            ],
          ),
        ),
      ),

      SizedBox(height: 12.h),

      // ── Bottom Row: Price + Actions ──
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Amount",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Rs.",
                    style: TextStyle(
                      color: AppColor.primaryColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    "${order.grandTotal ?? 0}",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20.sp,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Action Buttons
          Row(
            children: [
              if (firstProduct != null)
                _buildActionButton(
                  label: "Product",
                  icon: Icons.visibility_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(
                        productId: firstProduct.productId,
                        categoryId: firstProduct.categoryId,
                      ),
                    ),
                  ),
                  outlined: true,
                ),
              if (isPendingTab) ...[
                SizedBox(width: 8.w),
                _buildActionButton(
                  label: "Details",
                  icon: Icons.arrow_forward_ios_rounded,
                  iconSize: 12,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(order: order),
                    ),
                  ),
                  outlined: false,
                ),
              ],

              // Track button for dispatched orders
              if (!isPendingTab &&
                  order.trackNumber != null &&
                  (order.trackNumber as String).isNotEmpty) ...[
                SizedBox(width: 8.w),
                _buildActionButton(
                  label: "Track",
                  icon: Icons.location_on_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LeopardsTrackingScreen(
                        trackNumber: order.trackNumber as String,
                      ),
                    ),
                  ),
                  outlined: false,
                ),
              ],
            ],
          ),
        ],
      ),
    ];
  }

  Widget _buildProductImage(dynamic firstProduct) {
    return Stack(
      children: [
        Container(
          height: 90.h,
          width: 80.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13.r),
            child:
                (firstProduct != null &&
                    firstProduct.images != null &&
                    firstProduct.images.isNotEmpty)
                ? Image.network(
                    Global.getImageUrl(firstProduct.images.first),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white38,
                        size: 28.sp,
                      ),
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white38,
                      size: 28.sp,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final row = Row(
      children: [
        Icon(
          icon,
          color: onTap != null
              ? AppColor.primaryColor
              : Colors.white.withValues(alpha: 0.5),
          size: 13.sp,
        ),
        SizedBox(width: 5.w),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: onTap != null
                  ? AppColor.primaryColor
                  : Colors.white.withValues(alpha: 0.75),
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              decoration: onTap != null ? TextDecoration.underline : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
    return onTap != null ? GestureDetector(onTap: onTap, child: row) : row;
  }

  Widget _buildBadge({
    required String label,
    required Color bgColor,
    required Color textColor,
    IconData? icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: bgColor.withValues(alpha: 0.7), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: bgColor, size: 11.sp),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: TextStyle(
              color: bgColor,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool outlined,
    double iconSize = 14,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: outlined
              ? Colors.transparent
              : AppColor.primaryColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: outlined
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(icon, color: Colors.white, size: iconSize.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isPendingTab) {
    return ListView(
      children: [
        SizedBox(height: 80.h),
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
                  isPendingTab
                      ? Icons.hourglass_empty_rounded
                      : Icons.local_shipping_outlined,
                  color: Colors.white.withValues(alpha: 0.4),
                  size: 44.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                isPendingTab ? "No Pending Orders" : "No Dispatched Orders",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                isPendingTab
                    ? "New orders will appear here"
                    : "Dispatched orders will show up here",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 13.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isStaleOrder(String? createdAt) {
    if (createdAt == null) return false;
    try {
      final created = DateTime.parse(createdAt);
      return DateTime.now().difference(created).inHours >= 48;
    } catch (_) {
      return false;
    }
  }

  Widget _buildPendingStatusDropdown({required String orderId}) {
    if (_processingOrders.contains(orderId)) {
      return Container(
        height: 30.h,
        width: 100.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: SpinKitThreeBounce(color: AppColor.primaryColor, size: 14.sp),
      );
    }

    Color _statusColor(String status) {
      switch (status) {
        case 'Pending':
          return AppColor.errorColor;
        case 'Dispatched':
          return AppColor.successColor;
        case 'Cancel':
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }

    return Container(
      height: 30.h,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        color: _statusColor("Pending").withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: _statusColor("Pending").withValues(alpha: 0.7),
        ),
      ),
      child: DropdownButton<String>(
        value: "Pending",
        underline: const SizedBox(),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.white70,
          size: 18.sp,
        ),
        dropdownColor: const Color(0xff2A1A0E),
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        items: [
          "Pending",
          "Dispatched",
          "Cancel",
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (newStatus) async {
          if (newStatus == "Dispatched") {
            setState(() => _processingOrders.add(orderId));
            try {
              final dispatchProvider = Provider.of<PendingToDispatchedProvider>(
                context,
                listen: false,
              );
              bool success = await dispatchProvider.updateOrderStatus(
                orderId: orderId,
                status: "dispatched",
              );
              if (success) {
                AppToast.success("Order moved to Dispatched");
              } else {
                AppToast.error("Failed to update");
              }
            } finally {
              if (mounted) setState(() => _processingOrders.remove(orderId));
            }
          } else if (newStatus == "Cancel") {
            _showCancelReasonDialog(orderId: orderId);
          }
        },
      ),
    );
  }

  void _showCancelReasonDialog({required String orderId}) {
    final TextEditingController reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xff2C1A0E), const Color(0xff1A1009)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 36.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 22.h),

                // Title Row
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.cancel_outlined,
                        color: Colors.redAccent,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cancel Order",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "This action cannot be undone",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 26.h),

                Text(
                  "Reason for cancellation",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  "Optional — customer will be notified",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 12.h),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: TextField(
                    controller: reasonController,
                    maxLines: 3,
                    maxLength: 200,

                    style: TextStyle(color: Colors.black, fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: "e.g. Out of stock, customer requested...",
                      hintStyle: TextStyle(
                        color: Colors.black.withValues(alpha: 0.3),
                        fontSize: 13.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(14.w),
                      counterStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 22.h),

                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        second: true,
                        text: "Keep Order",
                        onTap: () => Navigator.pop(ctx),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Consumer<CancelOrderProvider>(
                        builder: (context, cancelProvider, _) {
                          return CustomButton(
                            text: cancelProvider.loading
                                ? "Cancelling..."
                                : "Confirm Cancel",
                            onTap: cancelProvider.loading
                                ? null
                                : () async {
                                    final reason = reasonController.text.trim();
                                    final success = await cancelProvider
                                        .cancelOrder(
                                          orderId: orderId,
                                          reason: reason.isNotEmpty
                                              ? reason
                                              : null,
                                        );
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    if (success) {
                                      AppToast.success("Order Cancelled");
                                    } else {
                                      AppToast.error("Failed to cancel order");
                                    }
                                  },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
