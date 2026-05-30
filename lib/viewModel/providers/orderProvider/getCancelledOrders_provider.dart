import 'package:flutter/material.dart';
import 'package:new_brand/models/orders/getMyOrders_model.dart';
import 'package:new_brand/viewModel/repository/orderRepository/getCancelledOrders_repository.dart';

class GetCancelledOrdersProvider extends ChangeNotifier {
  final GetCancelledOrdersRepository _repo = GetCancelledOrdersRepository();

  GetMyPendingOrders? model;
  bool loading = false;

  List<Orders> get orders => model?.orders ?? [];

  Future<void> fetchCancelledOrders({bool isRefresh = false}) async {
    if (loading) return;
    if (isRefresh) model = null;
    loading = true;
    notifyListeners();
    try {
      model = await _repo.getCancelledOrders();
    } catch (e) {
      debugPrint('GetCancelledOrdersProvider error: $e');
    }
    loading = false;
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
