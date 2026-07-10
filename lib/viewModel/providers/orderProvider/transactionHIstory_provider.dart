import 'package:flutter/material.dart';
import 'package:new_brand/models/orders/payment/transactionhistory_model.dart';
import 'package:new_brand/viewModel/repository/orderRepository/paymentRepository/transactionHistory_repository.dart';

class TransactionHistoryProvider with ChangeNotifier {
  final GetTransactionRepository _repo = GetTransactionRepository();

  bool isLoading = false;
  String? error;

  List<Transactions> transactions = [];
  int page = 1;
  bool hasMore = true;

  Future<void> fetchTransactions({bool refresh = false}) async {
    if (isLoading) return;

    if (refresh) {
      page = 1;
      transactions.clear();
      hasMore = true;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final res = await _repo.getTransaction(page: page);

      if (res.transactions != null && res.transactions!.isNotEmpty) {
        transactions.addAll(res.transactions!);
        page++;
      } else {
        hasMore = false;
      }
    } catch (e) {
      error = e.toString();
      debugPrint("Transaction Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
