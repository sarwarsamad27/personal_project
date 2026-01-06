import 'package:flutter/material.dart';
import 'package:new_brand/models/orders/payment/transactionhistory_model.dart';
import 'package:new_brand/viewModel/repository/orderRepository/paymentRepository/transactionHistory_repository.dart';

class TransactionHistoryProvider with ChangeNotifier {
  final GetTransactionRepository _repo = GetTransactionRepository();

  bool _isLoading = false;
  TransactionHistoryModel? _historyData;
  String? _error;

  bool get isLoading => _isLoading;
  TransactionHistoryModel? get historyData => _historyData;
  String? get error => _error;

  List<Transactions> get transactions => _historyData?.transactions ?? [];

  Future<void> fetchTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _historyData = await _repo.getTransaction();
    } catch (e) {
      _error = e.toString();
      debugPrint("Transaction Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
