import 'package:flutter/material.dart';
import 'package:new_brand/models/orders/getDeliveredOrder_model.dart';
import 'package:new_brand/viewModel/repository/orderRepository/getDeliveredOrder_repository.dart';

class GetDeliveredOrderProvider extends ChangeNotifier {
  final GetDeliveredOrderRepository _repo = GetDeliveredOrderRepository();

  bool isLoading = false;
  List<Orders> orders = [];
  int page = 1;
  bool hasMore = true;

  Future<void> fetchDeliveredOrders({bool refresh = false}) async {
    if (isLoading) return;

    if (refresh) {
      page = 1;
      orders.clear();
      hasMore = true;
    }

    isLoading = true;
    notifyListeners();

    try {
      final res = await _repo.getDeliveredOrder(page: page);

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
