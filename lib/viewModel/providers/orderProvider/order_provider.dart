import 'package:flutter/material.dart';
import 'package:new_brand/models/orders/getMyOrders_model.dart';
import 'package:new_brand/viewModel/repository/orderRepository/getOrder_repository.dart';

class GetMyOrdersProvider extends ChangeNotifier {
  final GetOrderRepository repository = GetOrderRepository();

  bool loading = false;
  bool loadMore = false;

  int page = 1;
  int limit = 10;

  GetMyPendingOrders? orderModel;

  Future<void> fetchOrders({
    bool isLoadMore = false,
    bool isRefresh = false,
  }) async {
    if (isLoadMore && loadMore) return; // 🚫 double call stop
    if (!isLoadMore && loading) return;

    if (isRefresh) {
      page = 1;
      orderModel = null;
    }

    isLoadMore ? loadMore = true : loading = true;
    notifyListeners();

    try {
      final newOrders = await repository.getOrders(page: page, limit: limit);

      if (newOrders.orders == null || newOrders.orders!.isEmpty) {
        // 🚫 No more data → page increment mat karo
        loading = false;
        loadMore = false;
        notifyListeners();
        return;
      }

      if (isLoadMore && orderModel != null) {
        orderModel!.orders!.addAll(newOrders.orders!);
      } else {
        orderModel = newOrders;
      }

      page++; // ✅ only when data exists
    } catch (e) {
      print("Order Fetch Error: $e");
    }

    loading = false;
    loadMore = false;
    notifyListeners();
  }

  void updateStatusAndRefresh() async {
    page = 1;
    orderModel = null;
    notifyListeners();

    await fetchOrders();
  }
}
