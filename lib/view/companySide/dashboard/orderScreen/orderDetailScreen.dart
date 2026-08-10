import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/utiles.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/productDetail/productDetailScreen.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customImageContainer.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/viewModel/providers/orderProvider/acceptOrder_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/order_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../../models/orders/getMyOrders_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final Orders order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _downloadingSlip = false;

  String _cleanLeopardsError(String? rawError) {
    if (rawError == null || rawError.trim().isEmpty) {
      return "Shipping slip could not be generated at this time.";
    }
    final lower = rawError.toLowerCase();
    if (lower.contains("block") || lower.contains("account")) {
      return "Courier service issue: Shipping slip not generated. Please retry or contact support.";
    }
    if (lower.contains("address") ||
        lower.contains("city") ||
        lower.contains("phone")) {
      return "Invalid delivery details. Shipping slip could not be generated.";
    }
    if (lower.contains("timeout") ||
        lower.contains("connection") ||
        lower.contains("network")) {
      return "Network timeout while connecting to courier service. Please retry.";
    }
    if (rawError.length < 80 &&
        !rawError.contains("{") &&
        !rawError.contains("<")) {
      return rawError;
    }
    return "Shipping slip not generated. Tap retry below to try again.";
  }

  Future<void> _downloadSlip(String url) async {
    if (_downloadingSlip) return;
    setState(() => _downloadingSlip = true);
    try {
      final orderTrackNo = widget.order.trackNumber ?? '';
      // Use backend endpoint — avoids Cloudinary auth issues
      final downloadUrl = orderTrackNo.isNotEmpty
          ? Global.downloadSlip(orderTrackNo)
          : Global.getImageUrl(url.trim());

      final response = await http
          .get(Uri.parse(downloadUrl), headers: {"Accept": "application/pdf"})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        if (mounted) {
          AppToast.error(
            "Shipping slip not generated or currently unavailable",
          );
        }
        return;
      }

      final bytes = response.bodyBytes;
      // Validate PDF Magic Header (%PDF -> [0x25, 0x50, 0x44, 0x46])
      final isPdf =
          bytes.length >= 4 &&
          bytes[0] == 0x25 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x44 &&
          bytes[3] == 0x46;

      if (!isPdf) {
        if (mounted) {
          AppToast.error("Shipping slip not generated yet");
        }
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final trackNo = orderTrackNo.isNotEmpty
          ? orderTrackNo
          : DateTime.now().millisecondsSinceEpoch.toString();
      final file = File("${dir.path}/shipping_slip_$trackNo.pdf");
      await file.writeAsBytes(response.bodyBytes, flush: true);
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done && mounted) {
        AppToast.show("Saved to Documents folder");
      }
    } catch (e) {
      if (mounted) {
        AppToast.error("Unable to download shipping slip");
      }
    } finally {
      if (mounted) setState(() => _downloadingSlip = false);
    }
  }

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
                        _buildRow(
                          "Address",
                          order.buyerDetails?.address ?? "N/A",
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Expanded(child: _dateBadge(order.createdAt)),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: _paymentBadge(
                                order.paymentMethod,
                                order.paymentStatus,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
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
                          _buildRow(
                            "Total Price",
                            "Rs ${product.totalPrice ?? 0}",
                          ),
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
                      final String? slip = provider.slipLink?.isNotEmpty == true
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

                      // 1. Valid Slip Link Exists -> Download Slip Button
                      if (slip != null && slip.isNotEmpty) {
                        return Column(
                          children: [
                            _statusBadge(currentStatus),
                            SizedBox(height: 12.h),
                            if (track != null && track.isNotEmpty) ...[
                              _trackBadge(track),
                              SizedBox(height: 12.h),
                            ],
                            CustomButton(
                              text: _downloadingSlip
                                  ? "Downloading..."
                                  : "📦 Download Shipping Slip",
                              onTap: _downloadingSlip
                                  ? null
                                  : () => _downloadSlip(slip),
                            ),
                          ],
                        );
                      }

                      // 2. Order Accepted / Dispatched, but Slip missing or generation failed
                      if (accepted) {
                        final errorMsg = _cleanLeopardsError(
                          provider.leopardsError,
                        );

                        return Column(
                          children: [
                            _statusBadge(currentStatus),
                            SizedBox(height: 12.h),
                            if (track != null && track.isNotEmpty) ...[
                              _trackBadge(track),
                              SizedBox(height: 12.h),
                            ],
                            Container(
                              padding: EdgeInsets.all(14.w),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: Colors.amber.withValues(alpha: 0.6),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.amber.shade400,
                                    size: 22.sp,
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Shipping Slip Not Generated",
                                          style: TextStyle(
                                            color: Colors.amber.shade300,
                                            fontSize: 13.5.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          errorMsg,
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11.5.sp,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 14.h),
                            CustomButton(
                              text: provider.isRetrying
                                  ? "Retrying..."
                                  : "🔄 Retry Shipping Slip Generation",
                              onTap: provider.isRetrying
                                  ? null
                                  : () async {
                                      final ordersProvider = context
                                          .read<GetMyOrdersProvider>();
                                      final ok = await provider
                                          .retryLeopardsBooking(
                                            orderId: order.sId!,
                                          );
                                      if (!ok) {
                                        AppToast.error(
                                          _cleanLeopardsError(
                                            provider.leopardsError,
                                          ),
                                        );
                                      } else {
                                        order.trackNumber =
                                            provider.trackNumber;
                                        order.slipLink = provider.slipLink;
                                        ordersProvider.updateOrderInList(
                                          order.sId!,
                                          trackNumber: provider.trackNumber,
                                          slipLink: provider.slipLink,
                                        );
                                        AppToast.show(
                                          "Shipping slip generated successfully!",
                                        );
                                      }
                                    },
                            ),
                          ],
                        );
                      }

                      // 3. Pending Order -> Accept Order & Book Shipment
                      return CustomButton(
                        text: provider.isLoading
                            ? "Processing..."
                            : "✅ Accept Order & Book Shipment",
                        onTap: provider.isLoading
                            ? null
                            : () async {
                                final ordersProvider = context
                                    .read<GetMyOrdersProvider>();
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
                                  if (order.slipLink != null &&
                                      order.slipLink!.isNotEmpty) {
                                    AppToast.show(
                                      "Order accepted & slip generated!",
                                    );
                                  }
                                } else {
                                  AppToast.error(
                                    provider.errorMessage ??
                                        "Something went wrong while accepting order",
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

  Widget _dateBadge(String? createdAt) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_month_rounded,
            color: Colors.white70,
            size: 14.sp,
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              _formatDate(createdAt ?? ""),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11.5.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentBadge(String? paymentMethod, String? paymentStatus) {
    final color = Utils.paymentColor(paymentStatus);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Utils.paymentIcon(paymentStatus), color: color, size: 14.sp),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              Utils.paymentLabel(paymentMethod, paymentStatus),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 11.5.sp,
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
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
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
