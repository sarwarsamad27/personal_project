import 'package:flutter/material.dart';
import 'package:new_brand/models/orders/pendingToDispatched_model.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/viewModel/repository/orderRepository/pendingToDispatched_repository.dart';

class PendingToDispatchedProvider extends ChangeNotifier {
  final PendingToDispatchedRepository repository =
      PendingToDispatchedRepository();


  bool loading = false;
  PendingToDispatchedModel? response;

  Future<bool> updateOrderStatus({required String orderId , required String status}) async {
    final token = await LocalStorage.getToken();
    loading = true;
    notifyListeners();

    try {
      response = await repository.pendingToDispatched(
        orderId: orderId,
        token: token ?? '', status: status,
      );

      loading = false;
      notifyListeners();

      if (response?.message != null) {
        return true; // success
      }
    } catch (e) {
      loading = false;
      notifyListeners();
    }

    return false;
  }
}

