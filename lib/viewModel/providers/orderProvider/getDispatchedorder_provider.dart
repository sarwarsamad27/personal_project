import 'package:flutter/material.dart';
import 'package:new_brand/models/orders/getDispatchedOrder_model.dart';
import 'package:new_brand/viewModel/repository/orderRepository/getDispatchedOrder_repository.dart';

class GetDispatchedOrderProvider extends ChangeNotifier {
  final GetDispatchedOrderRepository repo = GetDispatchedOrderRepository();

  GetDispatchedOrderModel? dispatchedModel;

  bool loading = false;
  bool loadMore = false;

  int page = 1;
  final int limit = 10;

  // FETCH + PAGINATION
  Future<void> fetchDispatchedOrders({bool isLoadMore = false, bool isRefresh = false}) async {
    if (loading || loadMore) return;

    if (isRefresh) {
      page = 1;
      dispatchedModel = null;
      notifyListeners();
    }

    if (isLoadMore) {
      loadMore = true;
      notifyListeners();
    } else {
      loading = true;
      notifyListeners();
    }

    try {
      final response = await repo.getDispatchedOrder();

      if (isLoadMore && dispatchedModel != null) {
        dispatchedModel!.orders!.addAll(response.orders ?? []);
      } else {
        dispatchedModel = response;
      }

      page++;
    } catch (e) {
      debugPrint("Error fetching dispatched orders: $e");
    }

    loading = false;
    loadMore = false;
    notifyListeners();
  }
}
