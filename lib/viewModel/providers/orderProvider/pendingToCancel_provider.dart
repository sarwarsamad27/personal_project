import 'package:flutter/material.dart';
import 'package:new_brand/models/orders/pendingToCancel_model.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/viewModel/repository/orderRepository/pendingToCancel_repo.dart';

class CancelOrderProvider extends ChangeNotifier {
  final CancelOrderRepository repository = CancelOrderRepository();

  bool loading = false;
  CancelOrderModel? response;

  Future<bool> cancelOrder({
    required String orderId,
    String? reason,
  }) async {
    final token = await LocalStorage.getToken();
    loading = true;
    notifyListeners();

    try {
      response = await repository.cancelOrder(
        orderId: orderId,
        token: token ?? '',
        reason: reason,
      );
      loading = false;
      notifyListeners();

      if (response?.message != null) return true;
    } catch (e) {
      loading = false;
      notifyListeners();
    }
    return false;
  }
}