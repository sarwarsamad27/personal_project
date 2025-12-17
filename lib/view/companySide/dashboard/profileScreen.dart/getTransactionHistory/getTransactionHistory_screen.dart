import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
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

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionHistoryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
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
          itemCount: provider.transactions.length,
          separatorBuilder: (_, __) =>
              Divider(color: Colors.white24, height: 20.h),
          itemBuilder: (context, index) {
            final tx = provider.transactions[index];

            final isDebit = tx.type == "debit";

            return Row(
              children: [
                CustomAppContainer(
                  padding: EdgeInsets.all(10.w),
                  child: Icon(
                    isDebit
                        ? LucideIcons.arrowDownCircle
                        : LucideIcons.checkCircle,
                    color: isDebit ? Colors.yellow : Colors.green,
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDebit
                            ? "Withdrawal (${tx.method ?? '-'})"
                            : "Order Amount",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        tx.createdAt ?? '',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${isDebit ? '-' : '+'} Rs. ${tx.amount}",
                      style: TextStyle(
                        color: isDebit ? Colors.yellow : Colors.green,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      tx.status ?? '',
                      style: TextStyle(
                        color: tx.status == "pending"
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
      },
    );
  }
}
