import 'package:flutter/material.dart';
import 'package:new_brand/models/orders/payment/transactionhistory_model.dart';
import 'package:new_brand/viewModel/repository/orderRepository/paymentRepository/transactionHistory_repository.dart';

class TransactionHistoryProvider with ChangeNotifier {
  final GetTransactionRepository _repo = GetTransactionRepository();
  static const int _pageSize = 20;

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
      final res = await _repo.getTransaction(page: page, limit: _pageSize);
      final fetched = res.transactions ?? [];

      if (fetched.isNotEmpty) {
        transactions.addAll(fetched);
        page++;
      }
      // A page shorter than the requested size means there's nothing left,
      // even if it wasn't empty — otherwise the trailing spinner spins
      // forever because a short list never scrolls far enough to trigger
      // the next fetch.
      hasMore = fetched.length == _pageSize;
    } catch (e) {
      error = e.toString();
      debugPrint("Transaction Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
