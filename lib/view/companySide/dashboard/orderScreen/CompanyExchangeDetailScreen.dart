// view/companySide/exchange/company_exchange_detail_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/models/chatThread/exchangeRequestModel.dart';
import 'package:new_brand/viewModel/providers/chatProvider/companyExchange.dart';
import 'package:provider/provider.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/toast.dart';

class CompanyExchangeDetailScreen extends StatefulWidget {
  final String exchangeId;
  const CompanyExchangeDetailScreen({super.key, required this.exchangeId});

  @override
  State<CompanyExchangeDetailScreen> createState() =>
      _CompanyExchangeDetailScreenState();
}

class _CompanyExchangeDetailScreenState
    extends State<CompanyExchangeDetailScreen> {
  ExchangeRequest? _exchange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final provider = context.read<CompanyExchangeProvider>();
    final found = provider.requests
        .where((r) => r.id == widget.exchangeId)
        .firstOrNull;
    setState(() => _exchange = found);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CompanyExchangeProvider>(builder: (context, provider, _) {
      final ex = provider.requests
          .where((r) => r.id == widget.exchangeId)
          .firstOrNull ?? _exchange;

      return Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: AppColor.primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: Text("Exchange Detail",
              style: TextStyle(
                  fontSize: 18.sp, fontWeight: FontWeight.bold)),
        ),
        body: ex == null
            ? const Center(child: Text("Not found"))
            : SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(ex),
                    SizedBox(height: 16.h),
                    _buildInfoCard(ex),
                    SizedBox(height: 16.h),
                    if (ex.courierPaidBy != null) _buildCourierCard(ex),
                    SizedBox(height: 16.h),

                    // ── Action Sections based on status ──────────
                    if (ex.isPending)
                      _buildDecisionSection(ex, provider),
                    if (ex.isReturnShipped)
                      _buildMarkReceivedSection(ex, provider),
                    if (ex.isReturnReceived)
                      _buildStartInspectionSection(ex, provider),
                    if (ex.isInspecting)
                      _buildInspectionResultSection(ex, provider),
                    if (ex.isApprovedInspection)
                      _buildResolutionSection(ex, provider),
                    if (ex.isReplacementShipped || ex.isRefunded)
                      _buildMarkCompletedSection(ex, provider),

                    // ── Return proof images ──────────────────────
                    if (ex.returnProofImages.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      _buildImagesCard(
                          "Return Proof Photos", ex.returnProofImages),
                    ],
                    if (ex.inspectionImages.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      _buildImagesCard(
                          "Inspection Photos", ex.inspectionImages),
                    ],
                    if (ex.images.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      _buildImagesCard(
                          "Customer Product Photos", ex.images),
                    ],
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
      );
    });
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader(ExchangeRequest ex) {
    final statusStyle = _statusStyle(ex.status);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(Icons.swap_horiz_rounded,
                color: AppColor.primaryColor, size: 28.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Exchange Request",
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                SizedBox(height: 4.h),
                Text(
                  _formatDate(ex.createdAt),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: statusStyle.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20.r),
              border:
                  Border.all(color: statusStyle.color.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusStyle.icon,
                    size: 14.sp, color: statusStyle.color),
                SizedBox(width: 4.w),
                Text(ex.statusLabel,
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: statusStyle.color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Card ─────────────────────────────────────────────────
  Widget _buildInfoCard(ExchangeRequest ex) {
    return _card(
      title: "Request Info",
      icon: Icons.info_outline,
      children: [
        _row("Reason", ex.reason ?? "N/A"),
        _row("Reason Type", _reasonLabel(ex.reasonCategory)),
        if (ex.resolutionType != null)
          _row("Resolution",
              ex.resolutionType == "refund" ? "Wallet Refund" : "Replacement"),
        if (ex.returnTrackingNumber?.isNotEmpty == true)
          _row("Return Tracking", ex.returnTrackingNumber!),
        if (ex.returnCourierName?.isNotEmpty == true)
          _row("Return Courier", ex.returnCourierName!),
        if (ex.inspectionNote?.isNotEmpty == true)
          _row("Inspection Note", ex.inspectionNote!),
        if (ex.replacementTrackingNumber?.isNotEmpty == true)
          _row("Replacement Tracking", ex.replacementTrackingNumber!),
        if (ex.refundAmount != null && ex.refundAmount! > 0)
          _row("Refund Amount", "Rs ${ex.refundAmount!.toStringAsFixed(0)}"),
      ],
    );
  }

  // ── Courier Card ──────────────────────────────────────────────
  Widget _buildCourierCard(ExchangeRequest ex) {
    final isSeller = ex.courierPaidBy == "seller";
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isSeller ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
            color: isSeller ? Colors.green[200]! : Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.local_shipping_outlined,
              color: isSeller ? Colors.green[700] : Colors.orange[700],
              size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(ex.courierCostLabel,
                style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: isSeller
                        ? Colors.green[800]
                        : Colors.orange[800])),
          ),
        ],
      ),
    );
  }

  // ── ACTIONS ───────────────────────────────────────────────────

  // 1. Accept / Deny
  Widget _buildDecisionSection(
      ExchangeRequest ex, CompanyExchangeProvider provider) {
    return _card(
      title: "Take Decision",
      icon: Icons.gavel,
      children: [
        Text(
          "Review the request and decide to accept or deny.",
          style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: provider.processing
                    ? null
                    : () => _showDenyDialog(ex, provider),
                icon: Icon(Icons.close, size: 18.sp),
                label: Text("Deny",
                    style: TextStyle(fontSize: 14.sp)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: provider.processing
                    ? null
                    : () => _showAcceptDialog(ex, provider),
                icon: Icon(Icons.check, size: 18.sp),
                label: Text("Accept",
                    style: TextStyle(fontSize: 14.sp)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 2. Mark received
  Widget _buildMarkReceivedSection(
      ExchangeRequest ex, CompanyExchangeProvider provider) {
    return _actionCard(
      title: "Mark Return Received",
      subtitle:
          "Confirm that you have received the returned parcel from the customer.",
      icon: Icons.inventory,
      color: Colors.teal,
      buttonText: "Mark as Received",
      loading: provider.processing,
      onPressed: () async {
        final ok = await provider.markReceived(ex.id ?? "");
        _showResult(ok, "Marked as received");
      },
    );
  }

  // 3. Start inspection
  Widget _buildStartInspectionSection(
      ExchangeRequest ex, CompanyExchangeProvider provider) {
    return _actionCard(
      title: "Start Inspection",
      subtitle: "Begin inspecting the returned product.",
      icon: Icons.search,
      color: Colors.purple,
      buttonText: "Start Inspection",
      loading: provider.processing,
      onPressed: () async {
        final ok = await provider.startInspection(ex.id ?? "");
        _showResult(ok, "Inspection started");
      },
    );
  }

  // 4. Inspection result
  Widget _buildInspectionResultSection(
      ExchangeRequest ex, CompanyExchangeProvider provider) {
    final _noteCtrl = TextEditingController();

    return _card(
      title: "Inspection Result",
      icon: Icons.verified,
      children: [
        TextField(
          controller: _noteCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: "Inspection Note",
            hintText: "Describe condition of returned product...",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r)),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: provider.processing
                    ? null
                    : () async {
                        if (_noteCtrl.text.trim().isEmpty) {
                          AppToast.error("Please enter inspection note");
                          return;
                        }
                        final ok =
                            await provider.submitInspectionResult(
                          exchangeId: ex.id ?? "",
                          result: "disputed",
                          note: _noteCtrl.text.trim(),
                        );
                        _showResult(ok, "Dispute raised");
                      },
                icon: Icon(Icons.warning_amber, size: 18.sp),
                label: const Text("Dispute"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: provider.processing
                    ? null
                    : () async {
                        final ok =
                            await provider.submitInspectionResult(
                          exchangeId: ex.id ?? "",
                          result: "approved",
                          note: _noteCtrl.text.trim(),
                        );
                        _showResult(ok, "Inspection approved");
                      },
                icon: Icon(Icons.check_circle, size: 18.sp),
                label: const Text("Approve"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 5. Resolution (replacement or refund)
  Widget _buildResolutionSection(
      ExchangeRequest ex, CompanyExchangeProvider provider) {
    if (ex.resolutionType == "refund") {
      return _buildRefundSection(ex, provider);
    } else {
      return _buildShipReplacementSection(ex, provider);
    }
  }

  Widget _buildShipReplacementSection(
      ExchangeRequest ex, CompanyExchangeProvider provider) {
    final _trackCtrl = TextEditingController();
    final _courierCtrl = TextEditingController();

    return _card(
      title: "Ship Replacement",
      icon: Icons.replay_circle_filled_outlined,
      children: [
        TextField(
          controller: _trackCtrl,
          decoration: InputDecoration(
            labelText: "Tracking Number *",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r)),
          ),
        ),
        SizedBox(height: 10.h),
        TextField(
          controller: _courierCtrl,
          decoration: InputDecoration(
            labelText: "Courier Name",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r)),
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: provider.processing
                ? null
                : () async {
                    if (_trackCtrl.text.trim().isEmpty) {
                      AppToast.error("Enter tracking number");
                      return;
                    }
                    final ok = await provider.shipReplacement(
                      exchangeId: ex.id ?? "",
                      trackingNumber: _trackCtrl.text.trim(),
                      courierName: _courierCtrl.text.trim(),
                    );
                    _showResult(ok, "Replacement shipped!");
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text("Ship Replacement",
                style: TextStyle(
                    fontSize: 15.sp, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildRefundSection(
      ExchangeRequest ex, CompanyExchangeProvider provider) {
    final _amtCtrl = TextEditingController();

    return _card(
      title: "Process Refund",
      icon: Icons.account_balance_wallet_outlined,
      children: [
        TextField(
          controller: _amtCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Refund Amount (Rs) *",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r)),
            prefixText: "Rs ",
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: provider.processing
                ? null
                : () async {
                    final amt = double.tryParse(_amtCtrl.text.trim());
                    if (amt == null || amt <= 0) {
                      AppToast.error("Enter valid amount");
                      return;
                    }
                    final ok = await provider.processRefund(
                      exchangeId: ex.id ?? "",
                      amount: amt,
                    );
                    _showResult(ok, "Refund processed!");
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text("Process Refund",
                style: TextStyle(
                    fontSize: 15.sp, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // 6. Mark completed
  Widget _buildMarkCompletedSection(
      ExchangeRequest ex, CompanyExchangeProvider provider) {
    return _actionCard(
      title: "Mark Completed",
      subtitle: ex.isReplacementShipped
          ? "Confirm that the replacement has been delivered."
          : "Confirm that the refund has been processed.",
      icon: Icons.check_circle_outline,
      color: Colors.green,
      buttonText: "Mark Completed",
      loading: provider.processing,
      onPressed: () async {
        final ok = await provider.markCompleted(ex.id ?? "");
        _showResult(ok, "Exchange completed!");
      },
    );
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
            return ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(url, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.broken_image,
                            color: Colors.grey, size: 24.sp),
                      )),
            );
          },
        ),
      ],
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────
  void _showAcceptDialog(
      ExchangeRequest ex, CompanyExchangeProvider provider) {
    String _resType = "replacement";
    final _noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r)),
          title: Text("Accept Exchange",
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800])),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Resolution type:",
                  style: TextStyle(
                      fontSize: 14.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              Row(
                children: [
                  _RadioChip(
                    label: "Replacement",
                    selected: _resType == "replacement",
                    onTap: () =>
                        setDialogState(() => _resType = "replacement"),
                  ),
                  SizedBox(width: 10.w),
                  _RadioChip(
                    label: "Refund",
                    selected: _resType == "refund",
                    onTap: () =>
                        setDialogState(() => _resType = "refund"),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _noteCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Note (optional)",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final ok = await provider.decide(
                  exchangeId: ex.id ?? "",
                  decision: "Accepted",
                  resolutionType: _resType,
                  note: _noteCtrl.text.trim(),
                );
                _showResult(ok, "Exchange accepted!");
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white),
              child: const Text("Accept"),
            ),
          ],
        ),
      ),
    );
  }

  void _showDenyDialog(
      ExchangeRequest ex, CompanyExchangeProvider provider) {
    final _noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: Text("Deny Exchange",
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red[800])),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _noteCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Reason for denial *",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (_noteCtrl.text.trim().isEmpty) {
                AppToast.error("Enter denial reason");
                return;
              }
              Navigator.pop(ctx);
              final ok = await provider.decide(
                exchangeId: ex.id ?? "",
                decision: "Denied",
                resolutionType: "replacement",
                note: _noteCtrl.text.trim(),
              );
              _showResult(ok, "Exchange denied");
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white),
            child: const Text("Deny"),
          ),
        ],
      ),
    );
  }

  // ── Utils ─────────────────────────────────────────────────────
  void _showResult(bool ok, String successMsg) {
    if (!mounted) return;
    if (ok) {
      AppToast.success(successMsg);
    } else {
      AppToast.error("Operation failed");
    }
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
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 20.sp, color: AppColor.primaryColor),
            SizedBox(width: 8.w),
            Text(title,
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
          ]),
          Divider(height: 20.h, color: Colors.grey[100]),
          ...children,
        ],
      ),
    );
  }

  Widget _actionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String buttonText,
    required bool loading,
    required VoidCallback onPressed,
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
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 20.sp, color: color),
            SizedBox(width: 8.w),
            Text(title,
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
          ]),
          SizedBox(height: 8.h),
          Text(subtitle,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[600])),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
              child: loading
                  ? SizedBox(
                      height: 20.w,
                      width: 20.w,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(buttonText,
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120.w,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500))),
          Expanded(
              child: Text(value,
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87))),
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
      case "seller_fault": return "Wrong Item Received";
      case "defective": return "Defective / Damaged";
      case "buyer_preference": return "Changed My Mind";
      case "size_color": return "Wrong Size / Color";
      default: return cat ?? "N/A";
    }
  }
}

_StatusStyle _statusStyle(String? status) {
  switch (status) {
    case "Pending": return _StatusStyle(Colors.orange, Icons.pending);
    case "Accepted": return _StatusStyle(Colors.blue, Icons.check_circle_outline);
    case "Denied": return _StatusStyle(Colors.red, Icons.cancel);
    case "ReturnShipped": return _StatusStyle(Colors.indigo, Icons.local_shipping);
    case "ReturnReceived": return _StatusStyle(Colors.teal, Icons.inventory);
    case "Inspecting": return _StatusStyle(Colors.purple, Icons.search);
    case "ApprovedInspection": return _StatusStyle(Colors.green, Icons.verified);
    case "Disputed": return _StatusStyle(Colors.red.shade400, Icons.warning_amber);
    case "ReplacementShipped": return _StatusStyle(Colors.indigo, Icons.local_shipping);
    case "Refunded": return _StatusStyle(Colors.green, Icons.account_balance_wallet);
    case "Completed": return _StatusStyle(Colors.green, Icons.check_circle);
    default: return _StatusStyle(Colors.grey, Icons.help_outline);
  }
}

class _StatusStyle {
  final Color color;
  final IconData icon;
  const _StatusStyle(this.color, this.icon);
}

class _RadioChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RadioChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColor.primaryColor.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
              color: selected ? AppColor.primaryColor : Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: selected ? AppColor.primaryColor : Colors.grey[600]),
        ),
      ),
    );
  }
}