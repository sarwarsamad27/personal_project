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

    final meta = tx.meta;
    final bankName = meta?.bankName?.trim() ?? '';
    final accountNumber = meta?.accountNumber?.trim() ?? '';
    final iban = meta?.iban?.trim() ?? '';
    final accountTitle = meta?.name?.trim() ?? '';
    final phone = meta?.phone?.trim() ?? '';

    // Bank withdrawal: bankName/accountNumber/iban are only ever set when
    // the seller withdrew to a bank account (see WalletTransaction.meta on
    // the backend) — meta.phone in that case is the seller's own account
    // phone used for OTP, not a payout number, so it's deliberately not
    // shown here.
    final isBankWithdrawal =
        isDebit && (bankName.isNotEmpty || accountNumber.isNotEmpty || iban.isNotEmpty);
    // Mobile-wallet withdrawal (JazzCash/Easypaisa): phone is the real
    // payout number here.
    final isMobileWithdrawal = isDebit && !isBankWithdrawal && phone.isNotEmpty;
    // Non-withdrawal transactions (credits, refunds, etc.) reuse meta.name
    // as a free-text order reference/note.
    final orderRef = !isDebit ? accountTitle : '';

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

              // Bank withdrawal — show every payout detail the seller submitted
              if (isBankWithdrawal) ...[
                if (accountTitle.isNotEmpty)
                  _row("Account Title", accountTitle),
                if (bankName.isNotEmpty) _row("Bank Name", bankName),
                if (accountNumber.isNotEmpty)
                  _row("Account Number", accountNumber),
                if (iban.isNotEmpty) _row("IBAN", iban),
              ]
              // JazzCash / Easypaisa withdrawal — phone is the real payout number here
              else if (isMobileWithdrawal) ...[
                if (accountTitle.isNotEmpty)
                  _row("Account Title", accountTitle),
                _row("Mobile Number", phone),
              ],
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
