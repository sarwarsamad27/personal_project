import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/getTransactionHistory/transactionDetail_screen.dart';
import 'package:new_brand/viewModel/providers/orderProvider/transactionHIstory_provider.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:provider/provider.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionHistoryProvider>().fetchTransactions();
    });
  }

  // ---------- Helpers (Premium Mapping) ----------

  String _norm(String? s) => (s ?? '').trim().toLowerCase();

  bool _isReversal(dynamic tx) {
    // Heuristic: status/type/method me "reversal/reversed/refund" ho to reversal treat karein
    final type = _norm(tx.type);
    final status = _norm(tx.status);
    final method = _norm(tx.method);

    return type.contains('reversal') ||
        status.contains('reversal') ||
        status.contains('reversed') ||
        status.contains('refund') ||
        method.contains('reversal') ||
        method.contains('refund');
  }

  bool _isDebit(dynamic tx) => _norm(tx.type) == 'debit';

  bool _isFailed(dynamic tx) {
    final status = _norm(tx.status);
    return status == 'failed' || status == 'fail' || status == 'error';
  }

  bool _isPending(dynamic tx) {
    final status = _norm(tx.status);
    return status == 'pending' ||
        status == 'processing' ||
        status == 'in_progress';
  }

  bool _isCompleted(dynamic tx) {
    final status = _norm(tx.status);
    return status == 'sent' ||
        status == 'success' ||
        status == 'succeeded' ||
        status == 'paid';
  }

  IconData _statusIcon(dynamic tx) {
    if (_isReversal(tx)) return LucideIcons.refreshCcw; // reversal icon
    if (_isFailed(tx)) return LucideIcons.xCircle;
    if (_isPending(tx)) return LucideIcons.clock3;
    if (_isCompleted(tx)) return LucideIcons.checkCircle2;

    // fallback: debit/credit style
    return _isDebit(tx)
        ? LucideIcons.arrowDownCircle
        : LucideIcons.arrowUpCircle;
  }

  Color _statusColor(dynamic tx) {
    if (_isReversal(tx))
      return Colors.yellow; // reversal unique color (purple-ish)
    if (_isFailed(tx)) return Colors.redAccent;
    if (_isPending(tx)) return Colors.amber;
    if (_isCompleted(tx)) return Colors.green;

    // fallback
    return _isDebit(tx) ? Colors.orangeAccent : Colors.greenAccent;
  }

  String _title(dynamic tx) {
    if (_isReversal(tx)) return "Amount Reversal";
    if (_isDebit(tx)) return "Withdrawal (${tx.method ?? '-'})";
    return "Transaction (${tx.method ?? '-'})";
  }

  String _prettyStatus(dynamic tx) {
    final s = _norm(tx.status);
    if (s.isEmpty) return '-';
    // standardize labels for UI
    if (_isCompleted(tx)) return 'Completed';
    if (_isFailed(tx)) return 'Failed';
    if (_isPending(tx)) return 'Pending';
    if (_isReversal(tx)) return 'Reversed';
    return tx.status ?? '-';
  }

  String _amountText(dynamic tx) {
    final isDebit = _isDebit(tx);
    // aapka existing format keep kiya
    return "${isDebit ? '-' : '+'} Rs. ${tx.amount ?? '-'}";
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionHistoryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Center(
            child: SpinKitThreeBounce(color: AppColor.primaryColor, size: 30.0),
          );
        }

        if (provider.error != null && provider.transactions.isEmpty) {
          return Center(
            child: Text(
              "Failed to load transactions\n${provider.error}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        if (provider.transactions.isEmpty) {
          return const Center(
            child: Text(
              "No transactions found",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          itemCount: provider.transactions.length,
          separatorBuilder: (_, __) =>
              Divider(color: Colors.white24, height: 18.h),
          itemBuilder: (context, index) {
            final tx = provider.transactions[index];

            final icon = _statusIcon(tx);
            final color = _statusColor(tx);

            return InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TransactionDetailScreen(tx: tx),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Row(
                  children: [
                    CustomAppContainer(
                      padding: EdgeInsets.all(10.w),
                      child: Icon(icon, color: color, size: 22.sp),
                    ),
                    SizedBox(width: 12.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _title(tx),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            tx.createdAt ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 10.w),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _amountText(tx),
                          style: TextStyle(
                            color: color,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.dot, size: 14.sp, color: color),
                            SizedBox(width: 4.w),
                            Text(
                              _prettyStatus(tx),
                              style: TextStyle(
                                color: color,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
