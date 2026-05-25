import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:new_brand/models/notification/company_notification_model.dart';
import 'package:new_brand/models/orders/getMyOrders_model.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/view/companySide/dashboard/orderScreen/CompanyExchangeDetailScreen.dart';
import 'package:new_brand/view/companySide/dashboard/orderScreen/orderDetailScreen.dart';
import 'package:new_brand/view/companySide/dashboard/orderScreen/orderScreen.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/productDetail/productDetailScreen.dart';
import 'package:new_brand/viewModel/providers/notificationProvider/company_notification_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class CompanyNotificationScreen extends StatefulWidget {
  const CompanyNotificationScreen({super.key});

  @override
  State<CompanyNotificationScreen> createState() =>
      _CompanyNotificationScreenState();
}

class _CompanyNotificationScreenState extends State<CompanyNotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<CompanyNotificationProvider>();
      // Fetch if not already loaded
      if (provider.notifications.isEmpty) {
        await provider.fetchNotifications();
      }
      // markAllRead already called from bell tap, but call again as safety net
      provider.markAllRead();
    });
  }

  void _handleTap(BuildContext context, CompanyNotificationModel n) {
    final type = n.type;
    final data = n.data;

    // ── Exchange → ExchangeDetailScreen ───────────────────────────
    if (type == 'EXCHANGE_STATUS' || type == 'EXCHANGE_DECISION') {
      final exchangeId = data['exchangeRequestId']?.toString() ?? '';
      if (exchangeId.isEmpty) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CompanyExchangeDetailScreen(exchangeId: exchangeId),
        ),
      );
      return;
    }

    // ── Low Stock / Out of Stock → ProductDetailScreen ─────────────
    if (type == 'LOW_STOCK' || type == 'OUT_OF_STOCK') {
      final productId = data['productId']?.toString() ?? '';
      final categoryId = data['categoryId']?.toString() ?? '';
      if (productId.isEmpty || categoryId.isEmpty) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ProductDetailScreen(productId: productId, categoryId: categoryId),
        ),
      );
      return;
    }

    // ── New Order → OrderScreen ────────────────────────────────────
    if (type == 'NEW_ORDER') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OrderScreen()),
      );
      return;
    }

    // ── Order status updates → OrderDetailScreen ──────────────────
    if ([
      'ORDER_STATUS',
      'ORDER_DELIVERED',
      'ORDER_DISPATCHED',
      'ORDER_RETURNED',
      'WALLET_DEBIT',
      'RETURN_COURIER_FEE',
    ].contains(type)) {
      final orderId = data['orderId']?.toString() ?? '';
      if (orderId.isEmpty) return;
      final orders =
          context.read<GetMyOrdersProvider>().orderModel?.orders ?? [];
      final Orders? match = orders.where((o) => o.sId == orderId).firstOrNull;
      if (match != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailScreen(order: match)),
        );
      }
      return;
    }

    // All other types → do nothing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17.sp,
          ),
        ),
      ),
      body: Consumer<CompanyNotificationProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 120.w,
                    child: Lottie.asset(
                      'assets/gif/notification_icon.json',
                      repeat: true,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColor.primaryColor,
            onRefresh: () => provider.fetchNotifications(),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              itemCount: provider.notifications.length,
              itemBuilder: (context, i) {
                final n = provider.notifications[i];
                return _NotifTile(
                  notification: n,
                  onTap: () => _handleTap(context, n),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final CompanyNotificationModel notification;
  final VoidCallback onTap;

  const _NotifTile({required this.notification, required this.onTap});

  IconData _icon(String type) {
    switch (type) {
      case 'NEW_ORDER':
        return Icons.shopping_bag_rounded;
      case 'ORDER_STATUS':
      case 'ORDER_DELIVERED':
      case 'ORDER_DISPATCHED':
        return Icons.local_shipping_rounded;
      case 'ORDER_RETURNED':
        return Icons.assignment_return_rounded;
      case 'WALLET_DEBIT':
        return Icons.arrow_upward_rounded;
      case 'WALLET_CREDIT':
        return Icons.arrow_downward_rounded;
      case 'REFUND_STATUS':
        return Icons.replay_rounded;
      case 'EXCHANGE_STATUS':
        return Icons.swap_horiz_rounded;
      case 'RETURN_COURIER_FEE':
        return Icons.receipt_long_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _iconColor(String type) {
    switch (type) {
      case 'NEW_ORDER':
        return const Color(0xFF10B981);
      case 'ORDER_STATUS':
      case 'ORDER_DELIVERED':
        return const Color(0xFF3B82F6);
      case 'ORDER_RETURNED':
        return const Color(0xFFEF4444);
      case 'WALLET_DEBIT':
        return const Color(0xFFEF4444);
      case 'WALLET_CREDIT':
        return const Color(0xFF10B981);
      case 'REFUND_STATUS':
        return const Color(0xFFF59E0B);
      default:
        return AppColor.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _iconColor(notification.type);
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isUnread ? color.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isUnread ? color.withValues(alpha: 0.2) : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(_icon(notification.type), color: color, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: isUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: const Color(0xFF1E1E2D),
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    timeago.format(notification.createdAt),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
