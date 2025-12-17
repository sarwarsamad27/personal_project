import 'package:flutter/material.dart';
import 'package:new_brand/models/orders/getReturnedOrder_model.dart';
import 'package:new_brand/viewModel/repository/orderRepository/getReturnedOrder_repository.dart';

class GetReturnedOrderProvider extends ChangeNotifier {
  final GetReturnedOrderRepository _repo = GetReturnedOrderRepository();

  bool isLoading = false;
  List<Orders> orders = [];
  int page = 1;
  bool hasMore = true;

  Future<void> fetchReturnedOrders({bool refresh = false}) async {
    if (isLoading) return;

    if (refresh) {
      page = 1;
      orders.clear();
      hasMore = true;
    }

    isLoading = true;
    notifyListeners();

    try {
      final res = await _repo.getReturnedOrder(page: page);

      if (res.orders != null && res.orders!.isNotEmpty) {
        orders.addAll(res.orders!);
        page++;
      } else {
        hasMore = false;
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    isLoading = false;
    notifyListeners();
  }
}
