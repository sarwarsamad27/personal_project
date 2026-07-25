import 'package:flutter/material.dart';
import 'package:new_brand/models/orders/getReturnedOrder_model.dart';
import 'package:new_brand/viewModel/repository/orderRepository/getReturnedOrder_repository.dart';

class GetReturnedOrderProvider extends ChangeNotifier {
  final GetReturnedOrderRepository _repo = GetReturnedOrderRepository();
  static const int _pageSize = 10;

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
      final res = await _repo.getReturnedOrder(page: page, limit: _pageSize);
      final fetched = res.orders ?? [];

      if (fetched.isNotEmpty) {
        orders.addAll(fetched);
        page++;
      }
      // A page shorter than the requested size means there's nothing left,
      // even if it wasn't empty — otherwise the trailing spinner spins
      // forever because a short list never scrolls far enough to trigger
      // the next fetch.
      hasMore = fetched.length == _pageSize;
    } catch (e) {
      debugPrint(e.toString());
    }

    isLoading = false;
    notifyListeners();
  }
}
