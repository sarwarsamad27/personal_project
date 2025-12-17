import 'package:flutter/material.dart';
import 'package:new_brand/models/orders/payment/transactionhistory_model.dart';
import 'package:new_brand/viewModel/repository/orderRepository/paymentRepository/transactionHistory_repository.dart';

class TransactionHistoryProvider with ChangeNotifier {
  final GetTransactionRepository _repo = GetTransactionRepository();

  bool isLoading = false;
  TransactionHistoryModel? historyData;

  Future<void> fetchTransactions() async {
    try {
      isLoading = true;
      notifyListeners();

      historyData = await _repo.getTransaction();
    } catch (e) {
      debugPrint("Transaction Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Transactions> get transactions =>
      historyData?.transactions ?? [];
}
