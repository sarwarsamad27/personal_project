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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TransactionHistoryProvider>();
      if (provider.transactions.isEmpty) {
        provider.fetchTransactions();
      }
    });
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final position = _scrollController.position;
      final nearBottom = position.pixels >= position.maxScrollExtent - 200;
      if (!nearBottom) return;

      final provider = context.read<TransactionHistoryProvider>();
      if (!provider.isLoading && provider.hasMore) {
        provider.fetchTransactions();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    final method = (tx.method ?? '').toString().trim();
    final m = method.toLowerCase();

    // ── Credits ──────────────────────────────────────────────────────────────
    if (!_isDebit(tx)) {
      if (m.contains('order delivered')) return 'Order Credited';
      if (m.contains('refund')) return 'Refund Received';
      if (m.contains('jazzcash') || m.contains('easypaisa'))
        return 'Top-Up ($method)';
      if (method.isNotEmpty) return method;
      return 'Amount Credited';
    }

    // ── Debits ───────────────────────────────────────────────────────────────
    if (m.contains('return courier') || m.contains('courier fee'))
      return 'Return Courier Fee';
    if (m.contains('refund reversal') || m.contains('reversal'))
      return 'Refund Reversal';
    if (m.contains('refund')) return 'Refund';
    if (method.isNotEmpty) return 'Withdrawal ($method)';
    return 'Withdrawal';
  }

  // Order reference from meta (if available)
  String? _orderRef(dynamic tx) {
    final name = tx.meta?.name?.toString().trim() ?? '';
    return name.isNotEmpty ? name : null;
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

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}  $hour:$minute $period';
    } catch (_) {
      return raw;
    }
  }
  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionHistoryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.transactions.isEmpty) {
          return Center(
            child: SpinKitThreeBounce(color: AppColor.whiteColor, size: 30.0),
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

        return RefreshIndicator(
          onRefresh: () => provider.fetchTransactions(refresh: true),
          color: AppColor.primaryColor,
          child: ListView.separated(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            itemCount:
                provider.transactions.length + (provider.hasMore ? 1 : 0),
            separatorBuilder: (_, __) =>
                Divider(color: Colors.white24, height: 18.h),
            itemBuilder: (context, index) {
              if (index == provider.transactions.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Center(
                    child: SpinKitThreeBounce(
                      color: AppColor.whiteColor,
                      size: 24,
                    ),
                  ),
                );
              }

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
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
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
                              _formatDate(tx.createdAt),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.sp,
                              ),
                            ),
                            if (_orderRef(tx) != null) ...[
                              SizedBox(height: 2.h),
                              Text(
                                _orderRef(tx)!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
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
          ),
        );
      },
    );
  }
}
