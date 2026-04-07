// view/companySide/dashboard/ChatListScreen/exchangeRequestpoll.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:new_brand/models/chatThread/chatModel.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/view/companySide/dashboard/ChatListScreen/full_image.dart';
import '../../../../viewModel/providers/chatProvider/chat_provider.dart';

class ExchangeRequestPoll extends StatelessWidget {
  final ChatMessage message;
  const ExchangeRequestPoll({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CompanyChatProvider>();
    final data = message.exchangeData;
    if (data == null) return const SizedBox.shrink();

    final status = p.normalizeStatus(data.status);
    final isPending = status == "pending";
    final isAccepted = status == "accepted";
    final isRejected = status == "rejected" || status == "denied";

    final statusColor = isPending
        ? const Color(0xFFE67E22)
        : isAccepted
        ? const Color(0xFF27AE60)
        : const Color(0xFFE74C3C);

    final statusIcon = isPending
        ? Icons.hourglass_top_rounded
        : isAccepted
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;

    final statusText = isPending
        ? 'Pending'
        : isAccepted
        ? 'Accepted'
        : 'Rejected';

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: statusColor.withOpacity(0.25), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.primaryColor.withOpacity(0.12),
                  AppColor.primaryColor.withOpacity(0.04),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                topRight: Radius.circular(18.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.swap_horiz_rounded,
                    color: AppColor.primaryColor,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Exchange Request",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primaryColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _formatTime(data.createdAt),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status chip
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: statusColor, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14.sp, color: statusColor),
                      SizedBox(width: 4.w),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Body ───────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order & Product
                _buildInfoTile(
                  icon: Icons.receipt_long_rounded,
                  label: "Order ID",
                  value: data.orderId ?? "N/A",
                  valueColor: Colors.black54,
                  fontSize: 12.sp,
                ),
                SizedBox(height: 10.h),
                _buildInfoTile(
                  icon: Icons.inventory_2_rounded,
                  label: "Product",
                  value: data.productName ?? "N/A",
                ),
                SizedBox(height: 10.h),

                // ✅ Quantity & Current Attributes — NEW
                if ((data.quantity ?? 0) > 0 ||
                    data.selectedColor.isNotEmpty ||
                    data.selectedSize.isNotEmpty) ...[
                  _buildAttributesSection(
                    title: "Item Details",
                    quantity: data.quantity,
                    colors: data.selectedColor,
                    sizes: data.selectedSize,
                    icon: Icons.shopping_bag_outlined,
                  ),
                  SizedBox(height: 12.h),
                ],

                // ✅ Requested Attributes (for Exchange) — NEW
                if (data.requestedColor != null ||
                    data.requestedSize != null) ...[
                  _buildAttributesSection(
                    title: "Requested Replacement",
                    colors: data.requestedColor != null
                        ? [data.requestedColor!]
                        : [],
                    sizes: data.requestedSize != null
                        ? [data.requestedSize!]
                        : [],
                    icon: Icons.published_with_changes_rounded,
                    titleColor: Colors.teal.shade700,
                  ),
                  SizedBox(height: 12.h),
                ],

                // ✅ Reason Category — NEW
                if (data.reasonCategory != null) ...[
                  _buildInfoTile(
                    icon: Icons.category_rounded,
                    label: "Category",
                    value: data.reasonCategoryLabel,
                    valueColor: AppColor.primaryColor,
                    bold: true,
                  ),
                  SizedBox(height: 10.h),
                ],

                // Reason
                _buildInfoTile(
                  icon: Icons.description_rounded,
                  label: "Reason",
                  value: data.reason ?? "N/A",
                  maxLines: 4,
                ),

                // ✅ Courier Cost Banner — NEW
                if (data.courierPaidBy != null) ...[
                  SizedBox(height: 14.h),
                  _buildCourierBanner(data.courierPaidBy!),
                ],

                // ✅ Resolution Type — NEW
                if (data.resolutionType != null && !isPending) ...[
                  SizedBox(height: 10.h),
                  _buildInfoTile(
                    icon: Icons.autorenew_rounded,
                    label: "Resolution",
                    value: data.resolutionType == "replacement"
                        ? "Replacement Product"
                        : "Refund",
                    valueColor: Colors.indigo,
                    bold: true,
                  ),
                ],

                // ✅ Company Note — NEW
                if ((data.companyNote ?? "").isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  _buildInfoTile(
                    icon: Icons.comment_rounded,
                    label: "Seller Note",
                    value: data.companyNote!,
                    maxLines: 3,
                    valueColor: Colors.black87,
                  ),
                ],

                // Images
                if (data.images.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Icon(
                        Icons.photo_library_rounded,
                        size: 15.sp,
                        color: Colors.black54,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        "Product Photos (${data.images.length})",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.images.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8.h,
                      crossAxisSpacing: 8.w,
                    ),
                    itemBuilder: (_, i) {
                      final url = p.imgUrl(data.images[i]);
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ImageViewerScreen(
                              imageUrls: data.images.map(p.imgUrl).toList(),
                              initialIndex: i,
                            ),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: Colors.black12,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.black12,
                              child: Icon(
                                Icons.broken_image,
                                size: 26.sp,
                                color: Colors.black38,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],

                // ── Action Buttons (Pending only) ──────────────
                if (isPending) ...[
                  SizedBox(height: 18.h),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: p.isProcessing ? "Wait..." : "Reject",
                          icon: Icons.close_rounded,
                          color: const Color(0xFFE74C3C),
                          onTap: p.isProcessing
                              ? null
                              : () => p.handleExchangeDecision(
                                  context,
                                  data.exchangeId ?? "",
                                  "Denied",
                                ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _ActionButton(
                          label: p.isProcessing ? "Wait..." : "Accept",
                          icon: Icons.check_rounded,
                          color: const Color(0xFF27AE60),
                          onTap: p.isProcessing
                              ? null
                              : () => p.handleExchangeDecision(
                                  context,
                                  data.exchangeId ?? "",
                                  "Accepted",
                                ),
                        ),
                      ),
                    ],
                  ),
                ],

                // ── Status Result (after decision) ─────────────
                if (!isPending) ...[
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 20.sp),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            isAccepted
                                ? "✅ Request accepted. Exchange slip sent to customer."
                                : "❌ Request rejected.",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ✅ Return shipping section when accepted
                  if (isAccepted) ...[
                    SizedBox(height: 14.h),
                    _ReturnShippingInfo(data: data),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Info tile ─────────────────────────────────────────────────
  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    int maxLines = 2,
    Color? valueColor,
    bool bold = false,
    double? fontSize,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15.sp, color: Colors.black38),
        SizedBox(width: 8.w),
        Expanded(
          child: RichText(
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(
                fontSize: fontSize ?? 13.sp,
                color: Colors.black87,
              ),
              children: [
                TextSpan(
                  text: "$label: ",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: valueColor ?? Colors.black87,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Courier Banner ────────────────────────────────────────────
  Widget _buildCourierBanner(String courierPaidBy) {
    Color bannerColor;
    IconData bannerIcon;
    String bannerText;

    switch (courierPaidBy) {
      case "seller":
        bannerColor = const Color(0xFF27AE60);
        bannerIcon = Icons.local_shipping_rounded;
        bannerText = "Courier cost: Company's responsibility";
        break;
      case "buyer":
        bannerColor = const Color(0xFFE67E22);
        bannerIcon = Icons.local_shipping_outlined;
        bannerText = "Return courier cost: Customer's responsibility";
        break;
      case "platform":
        bannerColor = Colors.blue;
        bannerIcon = Icons.support_rounded;
        bannerText = "Courier cost: Platform will handle";
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: bannerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: bannerColor.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(bannerIcon, size: 18.sp, color: bannerColor),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              bannerText,
              style: TextStyle(
                fontSize: 12.sp,
                color: bannerColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return "";
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inDays == 0) return DateFormat('HH:mm').format(date);
      if (difference.inDays == 1) return "Yesterday";
      if (difference.inDays < 7) return DateFormat('EEEE').format(date);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return "";
    }
  }

  // ── Attributes Section ─────────────────────────────────────────
  Widget _buildAttributesSection({
    required String title,
    required IconData icon,
    int? quantity,
    List<String> colors = const [],
    List<String> sizes = const [],
    Color? titleColor,
  }) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: (titleColor ?? Colors.black87).withOpacity(0.04),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: (titleColor ?? Colors.black87).withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.sp, color: titleColor ?? Colors.black54),
              SizedBox(width: 6.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: titleColor ?? Colors.black87,
                ),
              ),
              if (quantity != null && quantity > 0) ...[
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    "Qty: $quantity",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (colors.isNotEmpty || sizes.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: [
                if (colors.isNotEmpty)
                  _buildTag("Color: ${colors.join(', ')}", Colors.blueGrey),
                if (sizes.isNotEmpty)
                  _buildTag("Size: ${sizes.join(', ')}", Colors.deepPurple),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Return Shipping Info Card ─────────────────────────────────────
class _ReturnShippingInfo extends StatelessWidget {
  final ExchangeRequestData data;
  const _ReturnShippingInfo({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_shipping_rounded,
                size: 18.sp,
                color: Colors.blue.shade700,
              ),
              SizedBox(width: 8.w),
              Text(
                "Waiting for Return Shipment",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            "Customer will ship the product back. You'll be notified when they enter the tracking details.",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.blue.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Action Button ────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey.shade300 : color,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: onTap == null
              ? []
              : [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.sp, color: Colors.white),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
