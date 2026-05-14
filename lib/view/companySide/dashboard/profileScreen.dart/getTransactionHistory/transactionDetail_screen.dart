import 'package:flutter/material.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/widgets/customBgContainer.dart';

import '../../../../../models/orders/payment/transactionhistory_model.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transactions tx;

  const TransactionDetailScreen({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final isDebit = (tx.type ?? '').toLowerCase() == 'debit';
    final amtSign = isDebit ? '- Rs.' : '+ Rs.';
    final amtColor = isDebit ? Colors.redAccent : Colors.greenAccent;

    // Clean up status label
    final status = _prettyStatus(tx.status ?? '');

    // Order reference stored in meta.name
    final orderRef = tx.meta?.name?.trim() ?? '';
    // Account/phone stored in meta.phone (for withdrawal transactions)
    final acctRef = tx.meta?.phone?.trim() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Transaction Detail",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: CustomBgContainer(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row("Type", isDebit ? "Debit (Withdrawn)" : "Credit (Received)"),
              _rowColored("Amount", "$amtSign ${tx.amount ?? '-'}", amtColor),
              _row("Method", tx.method ?? "-"),
              _row("Status", status),
              _row("Date", _fmt(tx.createdAt)),
              const Divider(color: Colors.white24),

              // Order reference (if available)
              if (orderRef.isNotEmpty) _row("Order ID", orderRef),

              // Account number (if available — for JazzCash/Easypaisa withdrawals)
              if (acctRef.isNotEmpty) _row("Account", acctRef),
            ],
          ),
        ),
      ),
    );
  }

  String _prettyStatus(String s) {
    switch (s.toLowerCase()) {
      case 'success':
      case 'sent':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      default:
        return s.isNotEmpty ? s : '-';
    }
  }

  String _fmt(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw).toLocal();
      const months = [
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
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final p = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}  $h:$m $p';
    } catch (_) {
      return raw;
    }
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowColored(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
