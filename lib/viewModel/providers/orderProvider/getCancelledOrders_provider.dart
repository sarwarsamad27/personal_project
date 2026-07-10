import 'package:flutter/material.dart';
import 'package:new_brand/models/orders/getMyOrders_model.dart';
import 'package:new_brand/viewModel/repository/orderRepository/getCancelledOrders_repository.dart';

class GetCancelledOrdersProvider extends ChangeNotifier {
  final GetCancelledOrdersRepository _repo = GetCancelledOrdersRepository();

  GetMyPendingOrders? model;
  bool loading = false;
  bool loadMore = false;

  int page = 1;
  final int limit = 20;

  List<Orders> get orders => model?.orders ?? [];

  Future<void> fetchCancelledOrders({
    bool isLoadMore = false,
    bool isRefresh = false,
  }) async {
    if (isLoadMore && loadMore) return;
    if (!isLoadMore && loading) return;

    if (isRefresh) {
      page = 1;
      model = null;
    }

    isLoadMore ? loadMore = true : loading = true;
    notifyListeners();

    try {
      final response = await _repo.getCancelledOrders(page: page, limit: limit);

      if (response.orders == null || response.orders!.isEmpty) {
        loading = false;
        loadMore = false;
        notifyListeners();
        return;
      }

      if (isLoadMore && model != null) {
        model!.orders!.addAll(response.orders!);
      } else {
        model = response;
      }

      page++;
    } catch (e) {
      debugPrint('GetCancelledOrdersProvider error: $e');
    }

    loading = false;
    loadMore = false;
    notifyListeners();
  }

  // Called from socket when an order is cancelled in real-time
  void prependFromSocket(Orders order) {
    model ??= GetMyPendingOrders(orders: []);
    model!.orders ??= [];
    final exists = model!.orders!.any((o) => o.sId == order.sId);
    if (!exists) {
      model!.orders!.insert(0, order);
      notifyListeners();
    }
  }
}
