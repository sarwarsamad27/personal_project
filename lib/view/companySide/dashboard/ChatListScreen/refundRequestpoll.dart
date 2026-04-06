import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:new_brand/models/chatThread/chatModel.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/view/companySide/dashboard/ChatListScreen/full_image.dart';
import '../../../../viewModel/providers/chatProvider/chat_provider.dart';

class RefundRequestPoll extends StatelessWidget {
  final ChatMessage message;
  const RefundRequestPoll({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CompanyChatProvider>();
    final data = message.refundData;
    if (data == null) return const SizedBox.shrink();

    final status = p.normalizeStatus(data.status);
    final isPending = status == "pending";
    final isAccepted = status == "accepted";

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
                  Colors.blue.withOpacity(0.12),
                  Colors.blue.withOpacity(0.04),
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
                    color: Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.blue.shade700,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Refund Request",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
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
                _buildInfoTile(
                  icon: Icons.description_rounded,
                  label: "Reason",
                  value: data.reason ?? "N/A",
                  maxLines: 4,
                ),

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

                // ── Action Buttons ──────────────────────────
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
                              : () => p.handleRefundDecision(
                                  context,
                                  data.refundId ?? "",
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
                              : () => p.handleRefundDecision(
                                  context,
                                  data.refundId ?? "",
                                  "Accepted",
                                ),
                        ),
                      ),
                    ],
                  ),
                ],

                // ── Status Result ─────────────────────────────
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
                                ? "✅ Refund approved. Amount will be credited to customer's wallet."
                                : "❌ Refund request rejected.",
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
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

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
}

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
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey.shade300 : color,
          borderRadius: BorderRadius.circular(12.r),
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
