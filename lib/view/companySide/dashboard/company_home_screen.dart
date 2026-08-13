import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:new_brand/viewModel/providers/chatProvider/chatThread_provider.dart';
import 'package:new_brand/viewModel/providers/chatProvider/companyExchange_provider.dart';
import 'package:new_brand/viewModel/providers/chatProvider/company_refund_provider.dart';
import 'package:new_brand/viewModel/providers/notificationProvider/company_notification_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/getDispatchedorder_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/order_provider.dart';
import 'package:new_brand/viewModel/providers/syncCoordinator_provider.dart';
import 'package:provider/provider.dart';

import 'package:new_brand/resources/app_version_checker.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/socketServices.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/view/companySide/auth/suspendedScreen.dart';
import 'package:new_brand/view/companySide/dashboard/ChatListScreen/chatList_screen.dart';
import 'package:new_brand/view/companySide/dashboard/dashboardScreen/dashboardScreen.dart';
import 'package:new_brand/view/companySide/dashboard/orderScreen/orderScreen.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/productCategoryScreen.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/profileScreen.dart';

// Requests that are still "live" — the seller still needs to look at them.
// Terminal states (a finished exchange, a finalized refund) drop out of the
// badge; everything else (including Denied/Rejected) stays visible, same as
// the exchange/refund list screens' own tab vocabulary.
int _activeExchangeCount(CompanyExchangeProvider p) =>
    p.requests.where((r) => r.status != "Completed").length;
int _activeRefundCount(CompanyRefundProvider p) =>
    p.requests.where((r) => r.status != "Refunded").length;

class CompanyHomeScreen extends StatefulWidget {
  const CompanyHomeScreen({super.key});

  @override
  State<CompanyHomeScreen> createState() => _CompanyHomeScreenState();
}

class _CompanyHomeScreenState extends State<CompanyHomeScreen> {
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);
  DateTime? lastPressed;

  final screens = const [
    HomeDashboard(),
    CategoryScreen(),
    CompanyChatListScreen(),
    OrderScreen(),
    ProfileScreen(),
  ];

  // Debounced so a burst of events (e.g. a request created then immediately
  // updated) only triggers one re-fetch each, not one per event.
  Timer? _exchangeRefreshDebounce;
  Timer? _refundRefreshDebounce;
  Timer? _notificationRefreshDebounce;

  // Kept so dispose() can remove exactly these callbacks — the socket is a
  // shared singleton, and off() without a handler would also wipe out other
  // screens' listeners for the same event name.
  void Function(dynamic)? _onExchangeNew;
  void Function(dynamic)? _onExchangeStatus;
  void Function(dynamic)? _onExchangeReturnShipped;
  void Function(dynamic)? _onRefundNew;
  void Function(dynamic)? _onRefundStatus;
  void Function(dynamic)? _onRefundReturnShipped;
  // This shell is the only place that lives for the whole session (unlike
  // dashboardScreen.dart, which only exists while the Home tab is active),
  // so it's the right place to keep the notification bell badge correct no
  // matter which tab the seller is on — every one of these events also
  // creates a notification row server-side.
  void Function(dynamic)? _onNewOrderForNotif;
  void Function(dynamic)? _onOrderStatusForNotif;
  void Function(dynamic)? _onWithdrawNewForNotif;
  void Function(dynamic)? _onWithdrawStatusForNotif;
  void Function(dynamic)? _onAccountSuspended;

  @override
  void initState() {
    super.initState();
    // Pre-fetch orders on startup so navbar badge shows immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetMyOrdersProvider>(context, listen: false).fetchOrders();
      Provider.of<GetDispatchedOrderProvider>(context, listen: false)
          .fetchDispatchedOrders();
      // Same idea for the Exchange/Refund badges on the Profile tab — fetch
      // once here so the count is correct even before the seller opens
      // Profile, mirroring the orders prefetch above.
      Provider.of<CompanyExchangeProvider>(context, listen: false)
          .fetchRequests();
      Provider.of<CompanyRefundProvider>(context, listen: false)
          .fetchRequests();
      // This screen only mounts once a session is confirmed active (app
      // start with a valid token, or right after login) — the one place
      // guaranteed to run whether or not the offline→online connectivity
      // transition fired while the app was closed/backgrounded. Without
      // this, items queued offline and never resynced while the app was
      // shut would sit as "Syncing…" forever even after reopening online.
      Provider.of<SyncCoordinator>(context, listen: false).syncAll();
      checkAppVersion(context);
    });

    // This shell (unlike the tab screens beneath it) stays mounted for the
    // whole session, so it's the right place to own live exchange/refund
    // updates — the badge then stays correct no matter which tab is open.
    _setupExchangeRefundSocket();
  }

  Future<void> _setupExchangeRefundSocket() async {
    final token = await LocalStorage.getToken() ?? "";
    if (token.isEmpty || !mounted) return;
    final socket = await SocketService().ensureConnected(
      baseUrl: Global.imageUrl,
      token: token,
    );
    if (socket == null || !mounted) return;

    _onExchangeNew = (_) => _scheduleExchangeRefresh();
    _onExchangeStatus = (_) => _scheduleExchangeRefresh();
    _onExchangeReturnShipped = (_) => _scheduleExchangeRefresh();
    _onRefundNew = (_) => _scheduleRefundRefresh();
    _onRefundStatus = (_) => _scheduleRefundRefresh();
    _onRefundReturnShipped = (_) => _scheduleRefundRefresh();
    _onNewOrderForNotif = (_) => _scheduleNotificationRefresh();
    _onOrderStatusForNotif = (_) => _scheduleNotificationRefresh();
    _onWithdrawNewForNotif = (_) => _scheduleNotificationRefresh();
    _onWithdrawStatusForNotif = (_) => _scheduleNotificationRefresh();

    socket.on("exchange:new", _onExchangeNew!);
    socket.on("exchange:status", _onExchangeStatus!);
    socket.on("exchange:return_shipped", _onExchangeReturnShipped!);
    socket.on("refund:new", _onRefundNew!);
    socket.on("refund:status", _onRefundStatus!);
    socket.on("refund:return_shipped", _onRefundReturnShipped!);
    socket.on("new_order", _onNewOrderForNotif!);
    socket.on("order_status_updated", _onOrderStatusForNotif!);
    socket.on("wallet:withdraw_new", _onWithdrawNewForNotif!);
    socket.on("wallet:withdraw_status", _onWithdrawStatusForNotif!);

    // Admin suspended this seller while they're already logged in — force
    // them out immediately instead of leaving them with full access
    // (orders, withdrawals, etc.) until they happen to log out on their
    // own. Mirrors the same SuspendedScreen shown at login time
    // (loginScreen.dart) when isSuspended is already true.
    _onAccountSuspended = (data) => _handleAccountSuspended(data);
    socket.on("account:suspended", _onAccountSuspended!);
  }

  Future<void> _handleAccountSuspended(dynamic data) async {
    if (!mounted) return;
    final reason = data is Map ? data['reason']?.toString() : null;
    final until = data is Map ? data['suspendedUntil']?.toString() : null;

    await LocalStorage.clearToken();
    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => SuspendedScreen(reason: reason, until: until),
      ),
      (_) => false,
    );
  }

  void _scheduleExchangeRefresh() {
    _exchangeRefreshDebounce?.cancel();
    _exchangeRefreshDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      context.read<CompanyExchangeProvider>().fetchRequests(
        forceRefresh: true,
      );
    });
    _scheduleNotificationRefresh();
  }

  void _scheduleRefundRefresh() {
    _refundRefreshDebounce?.cancel();
    _refundRefreshDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      context.read<CompanyRefundProvider>().fetchRequests();
    });
    _scheduleNotificationRefresh();
  }

  // Refreshes the notification bell badge (unread count + list) so it stays
  // correct no matter which tab is open, instead of only updating the next
  // time the seller happens to visit the dashboard/notification screen.
  void _scheduleNotificationRefresh() {
    _notificationRefreshDebounce?.cancel();
    _notificationRefreshDebounce = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      context.read<CompanyNotificationProvider>().fetchNotifications();
    });
  }

  @override
  void dispose() {
    _exchangeRefreshDebounce?.cancel();
    _refundRefreshDebounce?.cancel();
    _notificationRefreshDebounce?.cancel();
    final socket = SocketService().socket;
    if (_onExchangeNew != null) socket?.off("exchange:new", _onExchangeNew);
    if (_onExchangeStatus != null) {
      socket?.off("exchange:status", _onExchangeStatus);
    }
    if (_onExchangeReturnShipped != null) {
      socket?.off("exchange:return_shipped", _onExchangeReturnShipped);
    }
    if (_onRefundNew != null) socket?.off("refund:new", _onRefundNew);
    if (_onRefundStatus != null) socket?.off("refund:status", _onRefundStatus);
    if (_onRefundReturnShipped != null) {
      socket?.off("refund:return_shipped", _onRefundReturnShipped);
    }
    if (_onNewOrderForNotif != null) {
      socket?.off("new_order", _onNewOrderForNotif);
    }
    if (_onOrderStatusForNotif != null) {
      socket?.off("order_status_updated", _onOrderStatusForNotif);
    }
    if (_onWithdrawNewForNotif != null) {
      socket?.off("wallet:withdraw_new", _onWithdrawNewForNotif);
    }
    if (_onWithdrawStatusForNotif != null) {
      socket?.off("wallet:withdraw_status", _onWithdrawStatusForNotif);
    }
    if (_onAccountSuspended != null) {
      socket?.off("account:suspended", _onAccountSuspended);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompanyChatThreadsProvider()..fetchThreads(),
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;

              final now = DateTime.now();
              if (lastPressed == null ||
                  now.difference(lastPressed!) > const Duration(seconds: 2)) {
                lastPressed = now;
                AppToast.error("Press again to exit");
                return;
              }

              final shouldExit = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Text("Do you want to quit?"),
                  content: const Text("Are you sure you want to exit the app?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("No"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Yes"),
                    ),
                  ],
                ),
              );

              if (shouldExit == true) SystemNavigator.pop();
            },
            child: ValueListenableBuilder<int>(
              valueListenable: _currentIndex,
              builder: (context, index, child) {
                return Scaffold(
                  extendBody: true,
                  body: screens[index],
                  bottomNavigationBar: _PremiumNavBar(
                    currentIndex: index,
                    onTap: (i) => _currentIndex.value = i,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _PremiumNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _PremiumNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = context.select<CompanyChatThreadsProvider, int>(
      (p) => p.unreadTotal,
    );

    final pendingCount = context.select<GetMyOrdersProvider, int>((p) =>
        (p.orderModel?.orders ?? [])
            .where((o) => o.status == "Pending")
            .length);

    final exchangeCount = context.select<CompanyExchangeProvider, int>(
      _activeExchangeCount,
    );
    final refundCount = context.select<CompanyRefundProvider, int>(
      _activeRefundCount,
    );

    final barHeight = 76.h;

    return SizedBox(
      height: barHeight + 26.h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // ✅ Base premium bar (pill)
          Container(
            height: barHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                _slot(
                  child: _NavItem(
                    icon: LucideIcons.house,
                    label: "Home",
                    selected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                ),
                _slot(
                  child: _NavItem(
                    icon: LucideIcons.package,
                    label: "Products",
                    selected: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                ),

                // ✅ center gap slot (equal width)
                _slot(child: const SizedBox.shrink()),

                _slot(
                  child: _NavItem(
                    icon: LucideIcons.receipt,
                    label: "Orders",
                    selected: currentIndex == 3,
                    onTap: () => onTap(3),
                    badgeCount: pendingCount,
                  ),
                ),
                _slot(
                  child: _NavItem(
                    icon: LucideIcons.user,
                    label: "Profile",
                    selected: currentIndex == 4,
                    onTap: () => onTap(4),
                    badgeCount: exchangeCount + refundCount,
                  ),
                ),
              ],
            ),
          ),

          // ✅ Floating center messages button
          Positioned(
            top: -6.h,
            child: _CenterMessagesButton(
              selected: currentIndex == 2,
              unreadCount: unread,
              onTap: () => onTap(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slot({required Widget child}) {
    return Expanded(child: child);
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 22.sp,
                    color: selected ? AppColor.primaryColor : Colors.grey,
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      right: -8.w,
                      top: -6.h,
                      child: _Badge(count: badgeCount),
                    ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: selected ? AppColor.primaryColor : Colors.grey,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterMessagesButton extends StatelessWidget {
  final bool selected;
  final int unreadCount;
  final VoidCallback onTap;

  const _CenterMessagesButton({
    required this.selected,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 66.w,
        height: 66.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: selected
                ? [
                    AppColor.primaryColor,
                    AppColor.primaryColor.withValues(alpha: 0.85),
                  ]
                : [Colors.white, Colors.white],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: selected ? Colors.transparent : Colors.black12,
            width: 1.2,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(
              LucideIcons.message_circle,
              size: 26.sp,
              color: selected ? Colors.white : AppColor.primaryColor,
            ),

            if (unreadCount > 0)
              Positioned(
                right: -2.w,
                top: -2.w,
                child: _Badge(count: unreadCount),
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    final text = count > 99 ? "99+" : "$count";
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
