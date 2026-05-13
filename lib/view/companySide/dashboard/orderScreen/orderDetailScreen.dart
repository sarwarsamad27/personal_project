import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/productDetail/productDetailScreen.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customImageContainer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/viewModel/providers/orderProvider/acceptOrder_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/order_provider.dart';
import 'package:provider/provider.dart';

import '../../../../models/orders/getMyOrders_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final Orders order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcceptOrderProvider>().reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Scaffold(
      backgroundColor: AppColor.appimagecolor,
      body: CustomBgContainer(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order Details",
                    style: TextStyle(
                      fontSize: 26.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  CustomAppContainer(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRow("Order ID", order.orderId ?? order.sId ?? ""),
                        _buildRow("Customer", order.buyerDetails?.name ?? ""),
                        _buildRow("Address", order.buyerDetails?.address ?? "N/A"),
                        _buildRow("Date", _formatDate(order.createdAt ?? "")),
                        _buildRow("Payment", "Cash on Delivery"),
                        if (order.trackNumber != null)
                          _buildRow("Track #", order.trackNumber!),
                        Divider(color: Colors.white.withValues(alpha: 0.3)),
                        for (final product in order.products!) ...[
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(
                                    productId: product.productId,
                                    categoryId: product.categoryId,
                                  ),
                                ),
                              );
                            },
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.r),
                                child: CustomImageContainer(
                                  height: 100.h,
                                  width: 100.w,
                                  child: Image.network(
                                    Global.getImageUrl(product.images!.first),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          _buildRow("Name", product.name ?? ""),
                          if (product.selectedSize != null &&
                              product.selectedSize!.isNotEmpty)
                            _buildRow("Size", product.selectedSize!.join(", ")),
                          _buildRow("Quantity", product.quantity.toString()),
                          _buildRow("Total Price", "Rs ${product.totalPrice ?? 0}"),
                          Divider(color: Colors.white.withValues(alpha: 0.2)),
                        ],
                        SizedBox(height: 12.h),
                        _buildRow("Grand Total", "Rs ${order.grandTotal ?? 0}"),
                      ],
                    ),
                  ),
                  SizedBox(height: 25.h),
                  Consumer<AcceptOrderProvider>(
                    builder: (context, provider, _) {
                      final String? slip =
                          provider.slipLink?.isNotEmpty == true
                              ? provider.slipLink
                              : (order.slipLink?.isNotEmpty == true
                                  ? order.slipLink
                                  : null);
                      final String? track =
                          provider.trackNumber ?? order.trackNumber;
                      final String currentStatus =
                          provider.updatedStatus ?? order.status ?? "Pending";
                      final bool accepted =
                          provider.isAccepted ||
                          currentStatus == "Dispatched" ||
                          (order.status != null && order.status != "Pending");

                      if (slip != null && slip.isNotEmpty) {
                        return Column(
                          children: [
                            _statusBadge(currentStatus),
                            SizedBox(height: 12.h),
                            if (track != null) ...[
                              _trackBadge(track),
                              SizedBox(height: 12.h),
                            ],
                            CustomButton(
                              text: "📦 Download Shipping Slip",
                              onTap: () async {
                                final messenger =
                                    ScaffoldMessenger.of(context);
                                try {
                                  final uri = Uri.parse(slip.trim());
                                  final launched = await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                  if (!launched) {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.platformDefault,
                                    );
                                  }
                                } catch (e) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text("Error: $e"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        );
                      }

                      if (accepted) {
                        // Leopards failed — show error + retry button
                        if (provider.leopardsError != null) {
                          return Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: Colors.orange),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Order accepted but Leopards booking failed",
                                            style: TextStyle(
                                              color: Colors.orange.shade800,
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            provider.leopardsError!,
                                            style: TextStyle(
                                              color: Colors.orange.shade700,
                                              fontSize: 11.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.h),
                              CustomButton(
                                text: provider.isRetrying
                                    ? "Retrying..."
                                    : "🔄 Retry Leopards Booking",
                                onTap: provider.isRetrying
                                    ? null
                                    : () async {
                                        final messenger = ScaffoldMessenger.of(context);
                                        final ordersProvider = context.read<GetMyOrdersProvider>();
                                        final ok = await provider.retryLeopardsBooking(
                                          orderId: order.sId!,
                                        );
                                        if (!ok) {
                                          messenger.showSnackBar(SnackBar(
                                            content: Text(provider.leopardsError ?? "Retry failed"),
                                            backgroundColor: Colors.red,
                                          ));
                                        } else {
                                          order.trackNumber = provider.trackNumber;
                                          order.slipLink    = provider.slipLink;
                                          ordersProvider.updateOrderInList(
                                            order.sId!,
                                            trackNumber: provider.trackNumber,
                                            slipLink: provider.slipLink,
                                          );
                                        }
                                      },
                              ),
                            ],
                          );
                        }

                        // Accepted, no slip yet (booking in progress)
                        return Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  "✅ Order Accepted! Slip generating...",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return CustomButton(
                        text: provider.isLoading
                            ? "Processing..."
                            : "✅ Accept Order & Book Shipment",
                        onTap: provider.isLoading
                            ? null
                            : () async {
                                final messenger = ScaffoldMessenger.of(context);
                                final ordersProvider =
                                    context.read<GetMyOrdersProvider>();
                                final token =
                                    await LocalStorage.getToken() ?? "";
                                final success = await provider.acceptOrder(
                                  token: token,
                                  orderId: order.sId!,
                                );
                                if (success) {
                                  order.status =
                                      provider.updatedStatus ?? "Dispatched";
                                  if (provider.trackNumber != null) {
                                    order.trackNumber = provider.trackNumber;
                                  }
                                  if (provider.slipLink != null) {
                                    order.slipLink = provider.slipLink;
                                  }
                                  ordersProvider.updateOrderInList(
                                    order.sId!,
                                    status: order.status,
                                    trackNumber: order.trackNumber,
                                    slipLink: order.slipLink,
                                  );
                                } else {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        provider.errorMessage ??
                                            "Something went wrong",
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined, color: Colors.blue),
          SizedBox(width: 8.w),
          Text(
            "Status: $status",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _trackBadge(String track) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping, color: Colors.green),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              "Track: $track",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return "${date.day.toString().padLeft(2, '0')} "
          "${_monthName(date.month)} "
          "${date.year} - ${_formatTime(date)}";
    } catch (e) {
      return isoDate;
    }
  }

  String _monthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime date) {
    int hour = date.hour;
    final period = hour >= 12 ? "PM" : "AM";
    hour = hour % 12;
    if (hour == 0) hour = 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return "$hour:$minute $period";
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$title:",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
