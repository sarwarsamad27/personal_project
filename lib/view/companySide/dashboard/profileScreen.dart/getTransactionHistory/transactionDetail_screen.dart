import 'package:flutter/material.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/widgets/customBgContainer.dart';

import '../../../../../models/orders/payment/transactionhistory_model.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transactions tx;

  const TransactionDetailScreen({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction Detail"),
        backgroundColor: AppColor.primaryColor,
      ),
      body: CustomBgContainer(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row("Type", tx.type ?? "-"),
              _row("Amount", "Rs. ${tx.amount}"),
              _row("Status", tx.status ?? "-"),
              _row("Method", tx.method ?? "-"),
              _row("Date", tx.createdAt ?? "-"),
              const Divider(),

              if (tx.meta != null) ...[
                _row("Name", tx.meta!.name ?? "-"),
                _row("Phone", tx.meta!.phone ?? "-"),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
