import 'package:flutter/material.dart';
import 'package:new_brand/models/orders/getDeliveredOrder_model.dart';
import 'package:new_brand/viewModel/repository/orderRepository/getDeliveredOrder_repository.dart';

class GetDeliveredOrderProvider extends ChangeNotifier {
  final GetDeliveredOrderRepository _repo = GetDeliveredOrderRepository();
  static const int _pageSize = 10;

  bool isLoading = false;
  List<Orders> orders = [];
  int page = 1;
  bool hasMore = true;

  Future<void> fetchDeliveredOrders({bool refresh = false}) async {
    if (isLoading) return;

    if (refresh) {
      page = 1;
      hasMore = true;
    }

    isLoading = true;
    notifyListeners();

    try {
      final res = await _repo.getDeliveredOrder(page: page, limit: _pageSize);
      final fetched = res.orders ?? [];

      if (refresh) {
        orders = List.from(fetched);
        page = fetched.length == _pageSize ? 2 : 1;
      } else if (fetched.isNotEmpty) {
        orders.addAll(fetched);
        page++;
      }
      hasMore = fetched.length == _pageSize;
    } catch (e) {
      debugPrint(e.toString());
    }

    isLoading = false;
    notifyListeners();
  }
}
