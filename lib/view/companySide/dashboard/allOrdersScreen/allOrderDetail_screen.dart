import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/models/orders/allOrders_model.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/utiles.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customImageContainer.dart';

class AllOrderDetailScreen extends StatelessWidget {
  final AllOrderItem order;
  const AllOrderDetailScreen({super.key, required this.order});

  Color _statusColor(String? status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
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
      return "${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute $period";
    } catch (_) {
      return "N/A";
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    final products = order.products ?? [];

    return Scaffold(
      backgroundColor: AppColor.appimagecolor,
      body: CustomBgContainer(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: SingleChildScrollView(
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
                      SizedBox(width: 14.w),
                      Text(
                        "Order Details",
                        style: TextStyle(
                          fontSize: 24.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // ── Status badge ──
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: statusColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.inventory_2_outlined, color: statusColor),
                        SizedBox(width: 8.w),
                        Text(
                          "Status: ${order.status ?? 'Unknown'}",
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // ── Exchange / Refund status ──
                  if (order.exchangeRequest != null) ...[
                    _requestCard(
                      title: "Exchange Request",
                      icon: Icons.swap_horiz_rounded,
                      color: Colors.deepPurple,
                      info: order.exchangeRequest!,
                    ),
                    SizedBox(height: 12.h),
                  ],
                  if (order.refundRequest != null) ...[
                    _requestCard(
                      title: "Refund Request",
                      icon: Icons.currency_exchange_rounded,
                      color: Colors.teal,
                      info: order.refundRequest!,
                    ),
                    SizedBox(height: 12.h),
                  ],

                  // ── Order + customer info ──
                  CustomAppContainer(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRow("Order ID", order.orderId ?? order.sId ?? ""),
                        _buildRow(
                          "Delivered To",
                          order.buyerDetails?.name ?? "N/A",
                        ),
                        if (order.buyerDetails?.phone != null)
                          _buildRow("Phone", order.buyerDetails!.phone!),
                        if (order.buyerDetails?.email != null)
                          _buildRow("Email", order.buyerDetails!.email!),
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
                        if (order.deliveredAt != null)
                          _buildRow(
                            "Delivered At",
                            _formatDate(order.deliveredAt),
                          ),
                        if (order.returnedAt != null)
                          _buildRow(
                            "Returned At",
                            _formatDate(order.returnedAt),
                          ),
                        if (order.trackNumber != null &&
                            order.trackNumber!.isNotEmpty)
                          _buildRow("Track #", order.trackNumber!),
                        if (order.cancelReason != null &&
                            order.cancelReason!.isNotEmpty)
                          _buildRow("Cancel Reason", order.cancelReason!),
                        Divider(color: Colors.white.withValues(alpha: 0.3)),
                        for (final product in products) ...[
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.r),
                              child: CustomImageContainer(
                                height: 100.h,
                                width: 100.w,
                                child:
                                    (product.images != null &&
                                        product.images!.isNotEmpty)
                                    ? Image.network(
                                        Global.getImageUrl(
                                          product.images!.first,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          _buildRow("Name", product.name ?? ""),
                          if (product.selectedSize != null &&
                              product.selectedSize!.isNotEmpty)
                            _buildRow("Size", product.selectedSize!.join(", ")),
                          _buildRow("Quantity", "${product.quantity ?? 0}"),
                          _buildRow(
                            "Item Price",
                            "Rs ${product.totalPrice ?? 0}",
                          ),
                          Divider(color: Colors.white.withValues(alpha: 0.2)),
                        ],
                        SizedBox(height: 12.h),
                        // Delivery charges deliberately not shown — only the
                        // products' own total, per seller requirement.
                        _buildRow(
                          "Order Total",
                          "Rs ${order.productsTotal}",
                        ),
                      ],
                    ),
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

  Widget _requestCard({
    required String title,
    required IconData icon,
    required Color color,
    required RequestInfo info,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  info.status ?? "Requested",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ),
          if (info.reason != null && info.reason!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              "Reason: ${info.reason}",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12.sp,
              ),
            ),
          ],
          if (info.resolutionType != null) ...[
            SizedBox(height: 6.h),
            Text(
              "Resolution: ${info.resolutionType}",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12.sp,
              ),
            ),
          ],
          if (info.refundAmount != null) ...[
            SizedBox(height: 6.h),
            Text(
              "Refund Amount: Rs ${info.refundAmount}",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12.sp,
              ),
            ),
          ],
          if (info.createdAt != null) ...[
            SizedBox(height: 6.h),
            Text(
              "Requested: ${_formatDate(info.createdAt)}",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 11.sp,
              ),
            ),
          ],
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
              _formatDate(createdAt),
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
