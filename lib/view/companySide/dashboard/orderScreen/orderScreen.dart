import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/productDetail/productDetailScreen.dart';
import 'package:new_brand/viewModel/providers/orderProvider/getDispatchedorder_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/order_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/pendingToCancel_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/pendingToDispatched_provider.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/paymentTabbar.dart';
import 'package:provider/provider.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customContainer.dart';

// ✅ IMPORTANT: Alias imports to avoid Orders name clash

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<GetMyOrdersProvider>(context, listen: false).fetchOrders();
    });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBgContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 50.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer2<GetMyOrdersProvider, GetDispatchedOrderProvider>(
                builder: (context, pendingProvider, dispatchedProvider, _) {
                  return PaymentTabBar(
                    onTabChanged: (index) {
                      if (index == 0) {
                        Provider.of<GetMyOrdersProvider>(
                          context,
                          listen: false,
                        ).fetchOrders(isRefresh: true); // Pending
                      } else {
                        Provider.of<GetDispatchedOrderProvider>(
                          context,
                          listen: false,
                        ).fetchDispatchedOrders(isRefresh: true); // Dispatched
                      }
                    },
                    firstTab: pendingTab(pendingProvider),
                    secondTab: dispatchedTab(dispatchedProvider),
                    firstTabbarName: "Pending Orders",
                    secondTabbarName: "Dispatched Orders",
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------- Pending Tab --------------------
  Widget pendingTab(GetMyOrdersProvider provider) {
    final list = (provider.orderModel?.orders ?? [])
        .where((e) => e.status == "Pending")
        .toList();

    return _buildOrderList(
      list: list,
      isPendingTab: true,
      pendingProvider: provider,
      isApiLoading: provider.loading,
      scrollController: _scrollController,
    );
  }

  // -------------------- Dispatched Tab --------------------
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
          ? ListView(
              children: const [
                SizedBox(
                  height: 300,
                  child: Center(
                    child: Text(
                      "No Orders Found",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: EdgeInsets.only(bottom: 50.h),

              controller: scrollController,
              itemCount:
                  list.length + ((pendingProvider?.loadMore ?? false) ? 1 : 0),
              separatorBuilder: (_, __) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                if (index == list.length &&
                    (pendingProvider?.loadMore ?? false)) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(0),
                      child: SpinKitThreeBounce(
                        color: AppColor.whiteColor,
                        size: 30.0,
                      ),
                    ),
                  );
                }

                // ✅ order is dynamic (could be my.Orders OR disp.Orders)
                final dynamic order = list[index];

                // ✅ products list (works for both models if field names same)
                final List<dynamic> products = (order.products ?? []);

                // safe first product for image/title
                final dynamic firstProduct = products.isNotEmpty
                    ? products.first
                    : null;

                return CustomAppContainer(
                  // padding: EdgeInsets.all(120.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // -------------------- PRODUCT IMAGE + VIEW PRODUCT BUTTON --------------------
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.network(
                              (firstProduct != null &&
                                      firstProduct.images != null &&
                                      firstProduct.images.isNotEmpty)
                                  ? Global.imageUrl + firstProduct.images.first
                                  : "",
                              height: 75.h,
                              width: 75.w,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image, color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 6.h),

                          TextButton(
                            onPressed: () {
                              if (firstProduct == null) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(
                                    productId: firstProduct.productId,
                                    categoryId: firstProduct.categoryId,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "View Product",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order ID: ${order.orderId ?? order.sId ?? ''}",
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 2.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    firstProduct?.name ?? "your product",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (isPendingTab)
                                  _buildPendingStatusDropdown(
                                    orderId: order.sId,
                                  ),

                                if (!isPendingTab)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.green.withOpacity(.2),
                                      border: Border.all(color: Colors.green),
                                    ),
                                    child: Text(
                                      "Dispatched",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            SizedBox(height: 6.h),

                            Text(
                              "Customer: ${order.buyerDetails?.name ?? ""}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14.sp,
                              ),
                            ),

                            SizedBox(height: 6.h),

                            // ✅ Premium line (minimal, no redesign)
                            Text(
                              "Items: ${products.length}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 14.sp,
                              ),
                            ),

                            SizedBox(height: 6.h),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Rs: ${order.grandTotal ?? 0}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // ✅ Changed: pass orderId only (no Orders type dependency)
  // ✅ Replace _buildPendingStatusDropdown in order_screen.dart with this

  Widget _buildPendingStatusDropdown({required String orderId}) {
    Color getStatusColor(String status) {
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
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: getStatusColor("Pending").withOpacity(0.2),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: getStatusColor("Pending")),
      ),
      child: DropdownButton<String>(
        value: "Pending",
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        dropdownColor: AppColor.primaryColor,
        style: TextStyle(color: Colors.white, fontSize: 13.sp),
        items: [
          "Pending",
          "Dispatched",
          "Cancel",
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (newStatus) async {
          if (newStatus == "Dispatched") {
            // ── existing dispatched logic ──
            final dispatchProvider = Provider.of<PendingToDispatchedProvider>(
              context,
              listen: false,
            );
            bool success = await dispatchProvider.updateOrderStatus(
              orderId: orderId,
              status: "dispatched",
            );
            if (success) {
              Provider.of<GetMyOrdersProvider>(
                context,
                listen: false,
              ).updateStatusAndRefresh();
              Provider.of<GetDispatchedOrderProvider>(
                context,
                listen: false,
              ).fetchDispatchedOrders(isRefresh: true);
              AppToast.success("Order moved to Dispatched");
            } else {
              AppToast.error("Failed to update");
            }
          } else if (newStatus == "Cancel") {
            // ── Premium cancel reason dialog ──
            _showCancelReasonDialog(orderId: orderId);
          }
        },
      ),
    );
  }

  // ✅ Premium Cancel Reason Bottom Sheet Dialog
  void _showCancelReasonDialog({required String orderId}) {
    final TextEditingController reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.appimagecolor.withOpacity(0.9),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              border: Border.all(color: Colors.white12),
            ),
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 32.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── drag handle ──
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // ── title ──
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cancel_outlined,
                        color: Colors.redAccent,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cancel Order",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "This action cannot be undone",
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // ── reason label ──
                Text(
                  "Reason for cancellation",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Optional — customer will be notified",
                  style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                ),
                SizedBox(height: 10.h),

                // ── text field ──
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: TextField(
                    controller: reasonController,
                    maxLines: 3,
                    maxLength: 200,
                    style: TextStyle(color: Colors.black, fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: "e.g. Out of stock, customer requested...",
                      hintStyle: TextStyle(
                        color: AppColor.textPrimaryLightColor,
                        fontSize: 13.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(14.w),
                      counterStyle: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // ── action buttons ──
                Row(
                  children: [
                    // keep order
                    Expanded(
                      child: CustomButton(
                        second: true,
                        text: "Keep Order",
                        onTap: () => Navigator.pop(ctx),
                      ),
                    ),

                    SizedBox(width: 12.w),

                    // confirm cancel
                    Expanded(
                      child: Consumer<CancelOrderProvider>(
                        builder: (context, cancelProvider, _) {
                          return CustomButton(
                            text: "Confirm Cancel",
                            onTap: () => cancelProvider.loading
                                ? null
                                : () async {
                                    final reason = reasonController.text.trim();

                                    // ✅ Save BEFORE any async call
                                    final ordersProvider =
                                        Provider.of<GetMyOrdersProvider>(
                                          context,
                                          listen: false,
                                        );

                                    // ✅ API call pehle
                                    bool success = await cancelProvider
                                        .cancelOrder(
                                          orderId: orderId,
                                          reason: reason.isNotEmpty
                                              ? reason
                                              : null,
                                        );

                                    // ✅ Ab pop karo
                                    if (ctx.mounted) Navigator.pop(ctx);

                                    // ✅ Saved reference use karo — no crash
                                    if (success) {
                                      ordersProvider.fetchOrders(
                                        isRefresh: true,
                                      );
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
