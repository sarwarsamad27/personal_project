import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/productDetail/productDetailScreen.dart';
import 'package:new_brand/viewModel/providers/orderProvider/getDispatchedorder_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/order_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/pendingToDispatched_provider.dart';
import 'package:new_brand/widgets/paymentTabbar.dart';
import 'package:provider/provider.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customContainer.dart';

// ✅ IMPORTANT: Alias imports to avoid Orders name clash
import 'package:new_brand/models/orders/getMyOrders_model.dart' as my;
import 'package:new_brand/models/orders/getDispatchedOrder_model.dart' as disp;

import 'orderDetailScreen.dart';

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
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
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
                          ).fetchDispatchedOrders(
                            isRefresh: true,
                          ); // Dispatched
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
              controller: scrollController,
              itemCount:
                  list.length + ((pendingProvider?.loadMore ?? false) ? 1 : 0),
              separatorBuilder: (_, __) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                if (index == list.length &&
                    (pendingProvider?.loadMore ?? false)) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(10),
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
                  padding: EdgeInsets.all(20.w),
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

                      // -------------------- RIGHT SIDE CONTENT --------------------
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row - Order ID + Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "#${(order.sId ?? "").toString().substring(0, 6)}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
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

                            SizedBox(height: 8.h),

                            Text(
                              firstProduct?.name ?? "Multiple Items",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                              ),
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
                                TextButton(
                                  onPressed: () {
                                    // ✅ Navigate to detail screen (product list inside)
                                    // For pending tab we have my.Orders model
                                    if (isPendingTab) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => OrderDetailScreen(
                                            order: order as my.Orders,
                                          ),
                                        ),
                                      );
                                    } else {
                                      // Dispatched model currently not wired to detail in your snippet.
                                      // If you want, create a DispatchedOrderDetailScreen similarly.
                                      AppToast.error(
                                        "Detail screen for dispatched not connected",
                                      );
                                    }
                                  },
                                  child: const Text(
                                    "View Detail",
                                    style: TextStyle(color: Colors.white),
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
  Widget _buildPendingStatusDropdown({required String orderId}) {
    Color getStatusColor(String status) {
      switch (status) {
        case 'Pending':
          return AppColor.errorColor;
        case 'Dispatched':
          return AppColor.successColor;
        case 'Cancel':
          return AppColor.primaryColor;
        default:
          return Colors.grey;
      }
    }

    // Since it's pending tab, status is always Pending in list.
    // Keep UI same: dropdown with value "Pending"
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
          }
        },
      ),
    );
  }
}
