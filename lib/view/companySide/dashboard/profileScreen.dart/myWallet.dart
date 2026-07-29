import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/socketServices.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/getDeleiveredOrder/getDeliveredOrder_screen.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/getReturnOrder/getReturnedOrder_screen.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/getTransactionHistory/getTransactionHistory_screen.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/widgets/wallet.dart';
import 'package:new_brand/viewModel/providers/orderProvider/getCompanyAmount_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/getDeliveredOrder_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/getReturnedOrder_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/transactionHIstory_provider.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/paymentTabbar.dart';
import 'package:provider/provider.dart';

class WalletHistoryScreen extends StatefulWidget {
  const WalletHistoryScreen({super.key});

  @override
  State<WalletHistoryScreen> createState() => _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends State<WalletHistoryScreen> {
  // Kept so dispose() can remove exactly these callbacks — socket.off with
  // no handler would wipe out every other screen's listener for the same
  // broadcast event (e.g. order_status_updated is also heard by
  // orderScreen.dart/dashboardScreen.dart).
  void Function(dynamic)? _onWithdrawNew;
  void Function(dynamic)? _onWithdrawStatus;
  void Function(dynamic)? _onOrderStatusUpdated;

  @override
  void initState() {
    super.initState();
    _setupWalletSocket();
  }

  // Live-refreshes this screen's three tabs (Transaction, Delivered,
  // Returned) whenever something that changes them happens elsewhere:
  // - a withdrawal submitted/approved/rejected (wallet:withdraw_new/status,
  //   emitted to this seller's own room — see paymentVerifyOTP_verify.js /
  //   transactionHistory.js)
  // - an order moving to Delivered/Returned, e.g. via courier/buyer/admin
  //   action (order_status_updated — same event orderScreen.dart already
  //   listens for, just not wired to these two tab providers)
  // Without this, the seller only sees the change after leaving and
  // re-entering this screen.
  Future<void> _setupWalletSocket() async {
    final token = await LocalStorage.getToken() ?? "";
    if (token.isEmpty || !mounted) return;
    final socket = await SocketService().ensureConnected(
      baseUrl: Global.imageUrl,
      token: token,
    );
    if (socket == null || !mounted) return;

    void refreshWallet(dynamic _) {
      if (!mounted) return;
      context.read<CompanyWalletProvider>().fetchCompanyWallet();
      context.read<TransactionHistoryProvider>().fetchTransactions(refresh: true);
    }

    void refreshOrderTabs(dynamic data) {
      if (!mounted) return;
      final status = data is Map ? data['status'] : null;
      if (status == 'Delivered') {
        context.read<GetDeliveredOrderProvider>().fetchDeliveredOrders(refresh: true);
      } else if (status == 'Returned') {
        context.read<GetReturnedOrderProvider>().fetchReturnedOrders(refresh: true);
      }
    }

    _onWithdrawNew = refreshWallet;
    _onWithdrawStatus = refreshWallet;
    _onOrderStatusUpdated = refreshOrderTabs;
    socket.on("wallet:withdraw_new", _onWithdrawNew!);
    socket.on("wallet:withdraw_status", _onWithdrawStatus!);
    socket.on("order_status_updated", _onOrderStatusUpdated!);
  }

  @override
  void dispose() {
    final socket = SocketService().socket;
    if (_onWithdrawNew != null) socket?.off("wallet:withdraw_new", _onWithdrawNew);
    if (_onWithdrawStatus != null) {
      socket?.off("wallet:withdraw_status", _onWithdrawStatus);
    }
    if (_onOrderStatusUpdated != null) {
      socket?.off("order_status_updated", _onOrderStatusUpdated);
    }
    super.dispose();
  }

  List<Map<String, dynamic>> transactions = [
    {
      'title': 'Order #1021 Received',
      'amount': '+ Rs. 2,500',
      'icon': LucideIcons.checkCircle,
      'color': Colors.green,
      'date': '5 Nov 2025',
      'status': 'completed',
    },
    {
      'title': 'Order #1019 Received',
      'amount': '+ Rs. 1,200',
      'icon': LucideIcons.checkCircle,
      'color': Colors.green,
      'date': '3 Nov 2025',
      'status': 'completed',
    },
  ];

  Widget buildTransactionTab() {
    return ListView.separated(
      itemCount: transactions.length,
      separatorBuilder: (_, __) => Divider(color: Colors.white24, height: 20.h),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return Row(
          children: [
            CustomAppContainer(
              padding: EdgeInsets.all(10.w),
              child: Icon(tx['icon'], color: tx['color']),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx['title'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    tx['date'],
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  tx['amount'],
                  style: TextStyle(
                    color: tx['color'],
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  tx['status'] == 'pending' ? "Pending" : "Completed",
                  style: TextStyle(
                    color: tx['status'] == 'pending'
                        ? Colors.yellow
                        : Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        backgroundColor: AppColor.primaryColor,
        centerTitle: true,
        title: Text(
          "Wallet",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: CustomBgContainer(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              Wallet(),
              SizedBox(height: 25.h),
              PaymentTabBar(
                firstTab: TransactionHistoryScreen(),
                secondTab: GetdeliveredorderScreen(),
                thirdTab: GetReturnedorderScreen(),
                secondTabbarName: 'Delivered',
                firstTabbarName: 'Transaction',
                thirdTabbarName: 'Returned',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
