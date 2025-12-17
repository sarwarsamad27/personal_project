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

  // ------------ FIRST TAB (DISPATCHED) ------------
  Widget firstTab(GetMyOrdersProvider provider) {
    final orders = provider.orderModel?.orders ?? [];
    final dispatched = orders.where((e) => e.status == "Dispatched").toList();

    return _buildOrderList(
      list: dispatched,
      provider: provider,
      scrollController: null,
    );
  }

  Widget secondTab(GetMyOrdersProvider provider) {
    final orders = provider.orderModel?.orders ?? [];
    final pending = orders.where((e) => e.status == "Pending").toList();

    return _buildOrderList(
      list: pending,
      provider: provider,
      scrollController: _scrollController,
    );
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

  Widget _buildOrderList({
    required List list,
    GetMyOrdersProvider? provider,
    bool isApiLoading = false,
    ScrollController? scrollController,
  }) {
    bool isLoading = provider?.loading == true && list.isEmpty;

    // 🔥 Loader jab API loading ho rahi ho
    if (isApiLoading && list.isEmpty) {
      return const Center(
        child: SpinKitThreeBounce(color: AppColor.whiteColor, size: 30),
      );
    }

    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: AppColor.primaryColor,
      onRefresh: () async {
        if (provider != null) {
          await provider.fetchOrders(isRefresh: true);
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
              itemCount: list.length + ((provider?.loadMore ?? false) ? 1 : 0),

              separatorBuilder: (_, __) => SizedBox(height: 16.h),

              itemBuilder: (context, index) {
                if (index == list.length && (provider?.loadMore ?? false)) {
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

                final order = list[index];
                final product = order.products!.first;

                Color getStatusColor(String status) {
                  switch (status) {
                    case 'Pending':
                      return AppColor.errorColor;
                    case 'Dispatched':
                      return AppColor.successColor;
                    default:
                      return Colors.grey;
                  }
                }

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
                              product.images!.isNotEmpty
                                  ? Global.imageUrl + product.images!.first
                                  : "",
                              height: 75.h,
                              width: 75.w,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image, color: Colors.white),
                            ),
                          ),

                          SizedBox(height: 6.h),

                          // VIEW PRODUCT BUTTON
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(
                                    productId: product.productId,
                                    categoryId: product.categoryId,
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
                                  "#${order.sId!.substring(0, 6)}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                // ---------------- Pending Tab Dropdown ----------------
                                if (provider != null) // pending tab
                                  _buildPendingStatusDropdown(order),

                                // ---------------- Dispatched Tab Simple Badge ----------------
                                if (provider == null) // dispatched tab
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
                              product.name ?? "",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 6.h),

                            Text(
                              "Customer: ${order.buyerDetails!.name}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14.sp,
                              ),
                            ),

                            SizedBox(height: 6.h),

                            // ---------------- QTY + PRICE (price moved below qty) ----------------
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Qty: ${product.quantity}",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 14.sp,
                                  ),
                                ),
                                if (provider == null)
                                  Text(
                                    "Rs: ${order.grandTotal}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                              ],
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (provider != null)
                                  Text(
                                    "Rs: ${order.grandTotal}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                if (provider != null)
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              OrderDetailScreen(order: order),
                                        ),
                                      );
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

  Widget dispatchedTab(GetDispatchedOrderProvider provider) {
    final list = (provider.dispatchedModel?.orders ?? [])
        .where((e) => e.status == "Dispatched")
        .toList();

    return _buildOrderList(
      list: list,
      provider: null,
      isApiLoading: provider.loading,
      scrollController: null,
    );
  }

  Widget pendingTab(GetMyOrdersProvider provider) {
    final list = (provider.orderModel?.orders ?? [])
        .where((e) => e.status == "Pending")
        .toList();

    return _buildOrderList(
      list: list,
      provider: provider,
      isApiLoading: provider.loading,
      scrollController: _scrollController,
    );
  }

  Widget _buildPendingStatusDropdown(order) {
    Color getStatusColor(String status) {
      switch (status) {
        case 'Pending':
          return AppColor.errorColor;
        case 'Dispatched':
          return AppColor.successColor;
        default:
          return Colors.grey;
      }
    }

    return Container(
      height: 30.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: getStatusColor(order.status!).withOpacity(0.2),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: getStatusColor(order.status!)),
      ),
      child: DropdownButton<String>(
        value: order.status,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        dropdownColor: AppColor.primaryColor,
        style: TextStyle(color: Colors.white, fontSize: 13.sp),
        items: [
          "Pending",
          "Dispatched",
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (newStatus) async {
          if (newStatus == "Dispatched") {
            final dispatchProvider = Provider.of<PendingToDispatchedProvider>(
              context,
              listen: false,
            );

            bool success = await dispatchProvider.updateOrderStatus(
              orderId: order.sId!,
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
