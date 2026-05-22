// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/models/chatThread/exchangeRequestModel.dart';
import 'package:new_brand/view/companySide/dashboard/orderScreen/leopards_tracking_screen.dart';
import 'package:new_brand/viewModel/providers/chatProvider/company_refund_provider.dart';
import 'package:provider/provider.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/toast.dart';

class CompanyRefundDetailScreen extends StatefulWidget {
  final String refundId;
  const CompanyRefundDetailScreen({super.key, required this.refundId});

  @override
  State<CompanyRefundDetailScreen> createState() =>
      _CompanyRefundDetailScreenState();
}

class _CompanyRefundDetailScreenState extends State<CompanyRefundDetailScreen> {
  ExchangeRequest? _refund;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final provider = context.read<CompanyRefundProvider>();
    final found = provider.requests
        .where((r) => r.id == widget.refundId)
        .firstOrNull;
    setState(() => _refund = found);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CompanyRefundProvider>(
      builder: (context, provider, _) {
        final rf =
            provider.requests
                .where((r) => r.id == widget.refundId)
                .firstOrNull ??
            _refund;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            backgroundColor: AppColor.primaryColor,
            foregroundColor: Colors.white,
            centerTitle: true,
            title: Text(
              "Refund Detail",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          body: rf == null
              ? const Center(child: Text("Not found"))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(rf),
                      SizedBox(height: 16.h),
                      _buildInfoCard(rf),
                      SizedBox(height: 16.h),

                      // ── Timeline ─────────────────────────────
                      _buildTimeline(rf),
                      SizedBox(height: 16.h),

                      // ── Actions ──────────────────────────────
                      if (rf.isPending) _buildDecisionSection(rf, provider),

                      // ReturnReceived: auto via Leopards webhook
                      if (rf.isReturnReceived) ...[
                        _buildAutoReceivedCard(),
                        SizedBox(height: 16.h),
                      ],

                      // Refunded: auto wallet credited via Leopards webhook
                      if (rf.isRefunded || rf.isCompleted) ...[
                        _buildRefundedCard(rf),
                        SizedBox(height: 16.h),
                      ],

                      // ── Images ───────────────────────────────
                      if (rf.returnProofImages.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        _buildImagesCard(
                          "Return Proof Photos",
                          rf.returnProofImages,
                        ),
                      ],
                      if (rf.inspectionImages.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        _buildImagesCard(
                          "Inspection Photos",
                          rf.inspectionImages,
                        ),
                      ],
                      if (rf.images.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        _buildImagesCard("Customer Product Photos", rf.images),
                      ],
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader(ExchangeRequest rf) {
    final statusStyle = _refundStatusStyle(rf.status);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.assignment_return_rounded,
              color: Colors.blue,
              size: 26.sp,
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
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      "Order: ",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _fmtOrderId(rf.orderId),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  _formatDate(rf.createdAt),
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: statusStyle.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: statusStyle.color.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusStyle.icon, size: 12.sp, color: statusStyle.color),
                SizedBox(width: 4.w),
                Text(
                  rf.statusLabel,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: statusStyle.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Card ─────────────────────────────────────────────────
  Widget _buildInfoCard(ExchangeRequest rf) {
    return _card(
      title: "Request Info",
      icon: Icons.info_outline,
      children: [
        if (rf.buyerName?.isNotEmpty == true) _row("Customer", rf.buyerName!),
        _row("Reason", rf.reason ?? "N/A"),
        _row("Category", _reasonLabel(rf.reasonCategory)),
        if (rf.refundAmount != null && rf.refundAmount! > 0)
          _row(
            "Refund Amount",
            "Rs ${rf.refundAmount!.toStringAsFixed(0)}",
            valueColor: Colors.green,
          ),
        if (rf.companyNote?.isNotEmpty == true) _row("Note", rf.companyNote!),
        if (rf.returnTrackingNumber?.isNotEmpty == true)
          _row(
            "Return Tracking",
            rf.returnTrackingNumber!,
            valueColor: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LeopardsTrackingScreen(
                    trackNumber: rf.returnTrackingNumber!,
                  ),
                ),
              );
            },
          ),
        if (rf.returnCourierName?.isNotEmpty == true)
          _row("Return Courier", rf.returnCourierName!),
        if (rf.inspectionNote?.isNotEmpty == true)
          _row("Inspection Note", rf.inspectionNote!),
        if (rf.disputeNote?.isNotEmpty == true)
          _row("Dispute Note", rf.disputeNote!, valueColor: Colors.red),
        if (rf.courierPaidBy != null) ...[
          SizedBox(height: 10.h),
          _buildCourierBanner(rf.courierPaidBy!),
        ],
      ],
    );
  }

  Widget _buildCourierBanner(String courierPaidBy) {
    final isBuyer = courierPaidBy == "buyer";
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isBuyer ? Colors.orange[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isBuyer ? Colors.orange[200]! : Colors.green[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 16.sp,
            color: isBuyer ? Colors.orange[700] : Colors.green[700],
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              isBuyer
                  ? "Return courier cost: Buyer's responsibility"
                  : "Seller will cover all courier costs",
              style: TextStyle(
                fontSize: 12.sp,
                color: isBuyer ? Colors.orange[700] : Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 1. Accept / Reject ────────────────────────────────────────
  Widget _buildDecisionSection(
    ExchangeRequest rf,
    CompanyRefundProvider provider,
  ) {
    return _card(
      title: "Take Decision",
      icon: Icons.gavel,
      children: [
        Text(
          "Review the refund request and decide.",
          style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: provider.processing
                    ? null
                    : () => _showRejectDialog(rf, provider),
                icon: Icon(Icons.close, size: 18.sp),
                label: Text("Reject", style: TextStyle(fontSize: 14.sp)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: provider.processing
                    ? null
                    : () => _showAcceptDialog(rf, provider),
                icon: Icon(Icons.check, size: 18.sp),
                label: Text("Accept", style: TextStyle(fontSize: 14.sp)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Timeline ─────────────────────────────────────────────────
  Widget _buildTimeline(ExchangeRequest rf) {
    final steps = [
      _TStep("Pending", "Pending", Icons.send_rounded),
      _TStep("Accepted", "Accepted", Icons.check_circle_outline),
      _TStep("Shipped", "ReturnShipped", Icons.local_shipping_rounded),
      _TStep("Received", "ReturnReceived", Icons.inventory_2_rounded),
    ];
    const statusOrder = [
      "Pending", "Accepted", "ReturnShipped", "ReturnReceived",
      "Refunded", "Completed",
    ];
    final currentIndex = statusOrder.indexOf(rf.status ?? "");
    final isDenied = rf.status == "Rejected";

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Return Progress", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
          SizedBox(height: 14.h),
          if (isDenied)
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10.r), border: Border.all(color: Colors.red[200]!)),
              child: Row(children: [
                Icon(Icons.cancel, color: Colors.red, size: 18.sp),
                SizedBox(width: 8.w),
                Text("Request Rejected", style: TextStyle(fontSize: 13.sp, color: Colors.red[700], fontWeight: FontWeight.bold)),
              ]),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(steps.length, (i) {
                  final step = steps[i];
                  final stepIdx = statusOrder.indexOf(step.statusKey);
                  final isDone = currentIndex >= stepIdx && stepIdx != -1;
                  final isCurrent = rf.status == step.statusKey;
                  final isLast = i == steps.length - 1;
                  return Row(children: [
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isCurrent ? 34.w : 28.w,
                        height: isCurrent ? 34.w : 28.w,
                        decoration: BoxDecoration(
                          color: isDone ? AppColor.primaryColor : Colors.grey[200],
                          shape: BoxShape.circle,
                          boxShadow: isCurrent ? [BoxShadow(color: AppColor.primaryColor.withOpacity(0.4), blurRadius: 8)] : null,
                        ),
                        child: Icon(step.icon, size: isCurrent ? 17.sp : 14.sp, color: isDone ? Colors.white : Colors.grey[400]),
                      ),
                      SizedBox(height: 5.h),
                      SizedBox(
                        width: 52.w,
                        child: Text(step.label, style: TextStyle(fontSize: 9.sp, color: isDone ? AppColor.primaryColor : Colors.grey[400], fontWeight: isCurrent ? FontWeight.w700 : FontWeight.normal), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                    if (!isLast)
                      Container(width: 18.w, height: 2, margin: EdgeInsets.only(bottom: 22.h), color: i < currentIndex ? AppColor.primaryColor : Colors.grey[200]),
                  ]);
                }),
              ),
            ),
        ],
      ),
    );
  }

  // ── Auto Received Card ────────────────────────────────────────
  Widget _buildAutoReceivedCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.teal[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2_rounded, color: Colors.teal[700], size: 30.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Return Received", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.teal[800])),
                SizedBox(height: 4.h),
                Text("Return parcel delivered via Leopards. Refund being processed automatically.", style: TextStyle(fontSize: 12.sp, color: Colors.teal[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Refunded Card ─────────────────────────────────────────────
  Widget _buildRefundedCard(ExchangeRequest rf) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 30.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Refund Auto-Processed", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.green[800])),
                SizedBox(height: 4.h),
                if (rf.refundAmount != null && rf.refundAmount! > 0)
                  Text("Rs ${rf.refundAmount!.toStringAsFixed(0)} credited to customer wallet.", style: TextStyle(fontSize: 12.sp, color: Colors.green[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Full-screen image viewer ──────────────────────────────────
  void _openFullScreen(BuildContext ctx, List<String> images, int initial) {
    final urls = images.map((img) => img.startsWith("http")
        ? img
        : "${Global.imageUrl}/$img").toList();
    Navigator.push(ctx, MaterialPageRoute(
      builder: (_) => _FullScreenImages(urls: urls, initialIndex: initial),
    ));
  }

  // ── Images Card ───────────────────────────────────────────────
  Widget _buildImagesCard(String title, List<String> images) {
    return _card(
      title: title,
      icon: Icons.photo_library_outlined,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: images.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8.h,
            crossAxisSpacing: 8.w,
          ),
          itemBuilder: (_, i) {
            final url = images[i].startsWith("http")
                ? images[i]
                : "${Global.imageUrl}/${images[i]}";
            return GestureDetector(
              onTap: () => _openFullScreen(context, images, i),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────
  void _showAcceptDialog(ExchangeRequest rf, CompanyRefundProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          "Accept Refund",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Accept this refund request? Customer will need to ship the product back.",
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
            ),
            if (rf.refundAmount != null && rf.refundAmount! > 0) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.currency_rupee_rounded,
                      color: Colors.green,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "Refund: Rs ${rf.refundAmount!.toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await provider.decide(
                refundId: rf.id ?? "",
                decision: "Accepted",
              );
              _showResult(ok, "Refund accepted!");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text("Accept"),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(ExchangeRequest rf, CompanyRefundProvider provider) {
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          "Reject Refund",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.red[800],
          ),
        ),
        content: TextField(
          controller: noteCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: "Reason for rejection *",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (noteCtrl.text.trim().isEmpty) {
                AppToast.error("Enter rejection reason");
                return;
              }
              Navigator.pop(ctx);
              final ok = await provider.decide(
                refundId: rf.id ?? "",
                decision: "Rejected",
                note: noteCtrl.text.trim(),
              );
              _showResult(ok, "Refund rejected");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Reject"),
          ),
        ],
      ),
    );
  }

  // ── Utils ─────────────────────────────────────────────────────
  void _showResult(bool ok, String successMsg) {
    if (!mounted) return;
    if (ok)
      AppToast.success(successMsg);
    else
      AppToast.error("Operation failed");
  }

  Widget _card({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(icon, size: 20.sp, color: AppColor.primaryColor),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Divider(height: 20.h, color: Colors.grey[100]),
          ...children,
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87,
                  decoration: onTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? s) {
    if (s == null) return "";
    try {
      final d = DateTime.parse(s);
      return "${d.day}/${d.month}/${d.year}";
    } catch (_) {
      return "";
    }
  }

  String _reasonLabel(String? cat) {
    switch (cat) {
      case "seller_fault":
        return "Wrong Item Received";
      case "defective":
        return "Defective / Damaged";
      case "buyer_preference":
        return "Changed My Mind";
      case "size_color":
        return "Wrong Size / Color";
      case "size_issue":
        return "Size Issue";
      case "wrong_item":
        return "Different Product";
      default:
        return cat ?? "N/A";
    }
  }
}

_RefundStatusStyle _refundStatusStyle(String? status) {
  switch (status) {
    case "Pending":
      return _RefundStatusStyle(Colors.orange, Icons.pending);
    case "Accepted":
      return _RefundStatusStyle(Colors.blue, Icons.check_circle_outline);
    case "Rejected":
      return _RefundStatusStyle(Colors.red, Icons.cancel);
    case "ReturnShipped":
      return _RefundStatusStyle(Colors.indigo, Icons.local_shipping);
    case "ReturnReceived":
      return _RefundStatusStyle(Colors.teal, Icons.inventory);
    case "Inspecting":
      return _RefundStatusStyle(Colors.purple, Icons.search);
    case "ApprovedInspection":
      return _RefundStatusStyle(Colors.green, Icons.verified);
    case "Disputed":
      return _RefundStatusStyle(Colors.red.shade400, Icons.warning_amber);
    case "Refunded":
      return _RefundStatusStyle(Colors.green, Icons.account_balance_wallet);
    case "Completed":
      return _RefundStatusStyle(Colors.green, Icons.check_circle);
    default:
      return _RefundStatusStyle(Colors.grey, Icons.help_outline);
  }
}

class _TStep {
  final String label;
  final String statusKey;
  final IconData icon;
  const _TStep(this.label, this.statusKey, this.icon);
}

class _RefundStatusStyle {
  final Color color;
  final IconData icon;
  const _RefundStatusStyle(this.color, this.icon);
}

String _fmtOrderId(String? raw) {
  if (raw == null || raw.isEmpty) return "N/A";
  if (raw.toUpperCase().startsWith("ORD-")) return raw.toUpperCase();
  final hex = RegExp(r'^[0-9a-fA-F]{24}$');
  if (hex.hasMatch(raw)) return "ORD-${raw.substring(16).toUpperCase()}";
  return raw;
}

// ── Full-screen swipeable image viewer ───────────────────────────────────────
class _FullScreenImages extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;
  const _FullScreenImages({required this.urls, required this.initialIndex});

  @override
  State<_FullScreenImages> createState() => _FullScreenImagesState();
}

class _FullScreenImagesState extends State<_FullScreenImages> {
  late PageController _pageCtrl;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageCtrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          "${_current + 1} / ${widget.urls.length}",
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageCtrl,
        itemCount: widget.urls.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (_, i) => InteractiveViewer(
          minScale: 0.8,
          maxScale: 4.0,
          child: Center(
            child: Image.network(
              widget.urls[i],
              fit: BoxFit.contain,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.white54)),
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image,
                color: Colors.white38,
                size: 64,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
