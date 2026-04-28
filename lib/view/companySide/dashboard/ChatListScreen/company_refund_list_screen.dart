// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/models/chatThread/exchangeRequestModel.dart';
import 'package:new_brand/view/companySide/dashboard/ChatListScreen/CompanyRefundDetailScreen.dart';
import 'package:new_brand/viewModel/providers/chatProvider/company_refund_provider.dart';
import 'package:provider/provider.dart';
import 'package:new_brand/resources/appColor.dart';

class CompanyRefundListScreen extends StatefulWidget {
  const CompanyRefundListScreen({super.key});

  @override
  State<CompanyRefundListScreen> createState() =>
      _CompanyRefundListScreenState();
}

class _CompanyRefundListScreenState extends State<CompanyRefundListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  static const _tabs = [
    _TabDef("All", null),
    _TabDef("Pending", "Pending"),
    _TabDef("Accepted", "Accepted"),
    _TabDef("In Progress", null, isInProgress: true),
    _TabDef("Refunded", "Refunded"),
    _TabDef("Rejected", "Rejected"),
  ];

  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoaded) {
        context.read<CompanyRefundProvider>().fetchRequests().then((_) {
          if (mounted) setState(() => _hasLoaded = true);
        });
      }
    });
    _tab.addListener(() {
      if (!_tab.indexIsChanging) {
        final filter = _tabs[_tab.index].statusFilter;
        context.read<CompanyRefundProvider>().fetchRequests(status: filter);
      }
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Refund Requests",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: Consumer<CompanyRefundProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColor.primaryColor),
            );
          }

          var requests = provider.requests;

          // In progress filter (client-side)
          if (_tabs[_tab.index].isInProgress) {
            const inProgressStatuses = [
              "ReturnShipped",
              "ReturnReceived",
              "Inspecting",
              "ApprovedInspection",
            ];
            requests = requests
                .where((r) => inProgressStatuses.contains(r.status))
                .toList();
          }

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_return_rounded,
                    size: 72.w,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "No refund requests",
                    style: TextStyle(fontSize: 17.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColor.primaryColor,
            onRefresh: provider.refresh,
            child: ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: requests.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, i) => _RefundCard(
                request: requests[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CompanyRefundDetailScreen(
                      refundId: requests[i].id ?? "",
                    ),
                  ),
                ).then((_) => provider.refresh()),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Refund Card ───────────────────────────────────────────────────────────────
class _RefundCard extends StatelessWidget {
  final ExchangeRequest request;
  final VoidCallback onTap;

  const _RefundCard({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusStyle = _refundStatusStyle(request.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.assignment_return_rounded,
                    color: Colors.blue,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.orderId ?? "Refund Request",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _formatDate(request.createdAt),
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusStyle.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: statusStyle.color.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusStyle.icon,
                        size: 12.sp,
                        color: statusStyle.color,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        request.statusLabel,
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

            Divider(height: 18.h, color: Colors.grey[100]),

            _row(Icons.description_outlined, request.reason ?? "N/A"),
            SizedBox(height: 6.h),
            _row(Icons.person_outline, request.buyerName ?? "Customer"),

            // ✅ Refund amount
            if (request.refundAmount != null && request.refundAmount! > 0) ...[
              SizedBox(height: 6.h),
              _row(
                Icons.currency_rupee_rounded,
                "Rs ${request.refundAmount!.toStringAsFixed(0)}",
                color: Colors.green,
              ),
            ],

            // ✅ Action hint
            if (request.status == "ReturnShipped") ...[
              SizedBox(height: 8.h),
              _actionHint(
                Icons.notifications_active,
                "Action: Mark parcel received",
                Colors.indigo,
              ),
            ],
            if (request.status == "ApprovedInspection") ...[
              SizedBox(height: 8.h),
              _actionHint(
                Icons.notifications_active,
                "Action: Finalize refund",
                Colors.green,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 15.sp, color: color ?? Colors.grey[500]),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 13.sp, color: color ?? Colors.black87),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _actionHint(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: color,
              fontWeight: FontWeight.w600,
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
}

// ── Tab Def ───────────────────────────────────────────────────────────────────
class _TabDef {
  final String label;
  final String? statusFilter;
  final bool isInProgress;
  const _TabDef(this.label, this.statusFilter, {this.isInProgress = false});
}

// ── Status Style ──────────────────────────────────────────────────────────────
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

class _RefundStatusStyle {
  final Color color;
  final IconData icon;
  const _RefundStatusStyle(this.color, this.icon);
}
