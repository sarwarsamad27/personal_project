// view/companySide/exchange/company_exchange_list_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/models/chatThread/exchangeRequestModel.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/view/companySide/dashboard/orderScreen/CompanyExchangeDetailScreen.dart';
import 'package:new_brand/viewModel/providers/chatProvider/companyExchange.dart';
import 'package:provider/provider.dart';
import 'package:new_brand/resources/appColor.dart';

class CompanyExchangeListScreen extends StatefulWidget {
  final ExchangeRequest? request;
  const CompanyExchangeListScreen({super.key, this.request});

  @override
  State<CompanyExchangeListScreen> createState() =>
      _CompanyExchangeListScreenState();
}

class _CompanyExchangeListScreenState extends State<CompanyExchangeListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  static const _tabs = [
    _TabDef("All", null),
    _TabDef("Pending", "Pending"),
    _TabDef("Accepted", "Accepted"),
    _TabDef("In Progress", null, isInProgress: true),
    _TabDef("Completed", "Completed"),
    _TabDef("Denied", "Denied"),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyExchangeProvider>().fetchRequests();
    });
    _tab.addListener(() {
      if (!_tab.indexIsChanging) {
        final filter = _tabs[_tab.index].statusFilter;
        context.read<CompanyExchangeProvider>().fetchRequests(status: filter);
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
          "Exchange Requests",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          padding: EdgeInsets.zero,
          controller: _tab,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: Consumer<CompanyExchangeProvider>(
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
              "ReplacementShipped",
              "Refunded",
            ];
            requests = requests
                .where((r) => inProgressStatuses.contains(r.status))
                .toList();
          }

          if (requests.isEmpty) {
            return _buildEmpty();
          }

          return RefreshIndicator(
            color: AppColor.primaryColor,
            onRefresh: provider.refresh,
            child: ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: requests.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, i) => _CompanyExchangeCard(
                request: requests[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CompanyExchangeDetailScreen(
                      profileId: requests[i].sellerProfileId ?? "",
                      userId: requests[i].buyerId ?? "",
                      exchangeId: requests[i].id ?? "",
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.swap_horiz_rounded, size: 72.w, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            "No exchange requests",
            style: TextStyle(fontSize: 17.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _CompanyExchangeCard extends StatelessWidget {
  final ExchangeRequest request;
  final VoidCallback onTap;

  const _CompanyExchangeCard({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusStyle = _companyStatusStyle(request.status);

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
                    color: AppColor.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.swap_horiz_rounded,
                    color: AppColor.primaryColor,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.buyerId != null
                            ? "${request.orderId!}"
                            : "Exchange Request",
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
                      width: 1,
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
            _row(
              Icons.local_shipping_outlined,
              request.courierCostLabel.isNotEmpty
                  ? request.courierCostLabel
                  : "Courier cost TBD",
              color: request.courierPaidBy == "buyer"
                  ? Colors.orange
                  : request.courierPaidBy == "seller"
                  ? Colors.green
                  : Colors.grey,
            ),

            if (request.status == "ReturnShipped") ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.indigo[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.indigo[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      size: 15.sp,
                      color: Colors.indigo,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "Action: Mark parcel received",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.indigo[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (request.status == "ApprovedInspection") ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      size: 15.sp,
                      color: Colors.green[700],
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      request.resolutionType == "refund"
                          ? "Action: Process refund"
                          : "Action: Ship replacement",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
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

class _TabDef {
  final String label;
  final String? statusFilter;
  final bool isInProgress;
  const _TabDef(this.label, this.statusFilter, {this.isInProgress = false});
}

_StatusStyle _companyStatusStyle(String? status) {
  switch (status) {
    case "Pending":
      return _StatusStyle(Colors.orange, Icons.pending);
    case "Accepted":
      return _StatusStyle(Colors.blue, Icons.check_circle_outline);
    case "Denied":
      return _StatusStyle(Colors.red, Icons.cancel);
    case "ReturnShipped":
      return _StatusStyle(Colors.indigo, Icons.local_shipping);
    case "ReturnReceived":
      return _StatusStyle(Colors.teal, Icons.inventory);
    case "Inspecting":
      return _StatusStyle(Colors.purple, Icons.search);
    case "ApprovedInspection":
      return _StatusStyle(Colors.green, Icons.verified);
    case "Disputed":
      return _StatusStyle(Colors.red.shade400, Icons.warning_amber);
    case "ReplacementShipped":
      return _StatusStyle(Colors.indigo, Icons.local_shipping);
    case "Refunded":
      return _StatusStyle(Colors.green, Icons.account_balance_wallet);
    case "Completed":
      return _StatusStyle(Colors.green, Icons.check_circle);
    default:
      return _StatusStyle(Colors.grey, Icons.help_outline);
  }
}

class _StatusStyle {
  final Color color;
  final IconData icon;
  const _StatusStyle(this.color, this.icon);
}
