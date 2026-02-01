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
    final isRejected = status == "rejected";

    final statusColor = isPending
        ? Colors.orange
        : isAccepted
            ? Colors.green
            : Colors.red;

    final statusIcon = isPending
        ? Icons.pending
        : isAccepted
            ? Icons.check_circle
            : Icons.cancel;

    final statusText = isPending
        ? 'Pending'
        : isAccepted
            ? 'Accepted'
            : 'Rejected';

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primaryColor.withOpacity(0.1),
            AppColor.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.swap_horiz,
                  color: AppColor.primaryColor,
                  size: 26.sp,
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
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    Text(
                      _formatTime(data.createdAt),
                      style: TextStyle(fontSize: 11.sp, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: statusColor, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 16.sp, color: statusColor),
                    SizedBox(width: 4.w),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Divider(height: 1, color: Colors.black12),
          SizedBox(height: 14.h),
          _buildInfoRow(Icons.shopping_bag, "Order", data.orderId ?? "N/A"),
          SizedBox(height: 10.h),
          _buildInfoRow(Icons.inventory_2, "Product", data.productName ?? "N/A"),
          SizedBox(height: 10.h),
          _buildInfoRow(Icons.description, "Reason", data.reason ?? "N/A", maxLines: 3),

          if (data.images.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              "Images",
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ImageViewerScreen(
                          imageUrls: data.images.map(p.imgUrl).toList(),
                          initialIndex: i,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: Colors.black12,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.black12,
                        child: Icon(Icons.broken_image, size: 26.sp, color: Colors.black38),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],

          if (isPending) ...[
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: p.isProcessing
                        ? null
                        : () => p.handleExchangeDecision(context, data.exchangeId ?? "", "Denied"),
                    icon: Icon(Icons.close, size: 18.sp),
                    label: Text(p.isProcessing ? "Wait..." : "Reject", style: TextStyle(fontSize: 14.sp)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: p.isProcessing
                        ? null
                        : () => p.handleExchangeDecision(context, data.exchangeId ?? "", "Accepted"),
                    icon: Icon(Icons.check, size: 18.sp),
                    label: Text(p.isProcessing ? "Wait..." : "Accept", style: TextStyle(fontSize: 14.sp)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (!isPending) ...[
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 20.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      isAccepted
                          ? "✅ Accepted. PDF sent to customer."
                          : isRejected
                              ? "❌ Request rejected."
                              : "❌ Request updated.",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.sp, color: Colors.black54),
        SizedBox(width: 8.w),
        Expanded(
          child: RichText(
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(fontSize: 13.sp, color: Colors.black87),
              children: [
                TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(text: value),
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
