import 'package:flutter/material.dart';
import 'package:new_brand/models/orders/allOrders_model.dart';
import 'package:new_brand/viewModel/repository/orderRepository/getAllOrdersAnyStatus_repository.dart';

class GetAllOrdersAnyStatusProvider extends ChangeNotifier {
  final GetAllOrdersAnyStatusRepository _repo =
      GetAllOrdersAnyStatusRepository();

  static const int _limit = 20;

  bool isLoading = false;
  String? error;
  List<AllOrderItem> orders = [];
  int page = 1;
  bool hasMore = true;

  DateTimeRange? _dateRange;
  DateTimeRange? get dateRange => _dateRange;

  Future<void> fetchOrders({bool refresh = false, DateTimeRange? range}) async {
    if (isLoading) return;

    if (refresh || range != _dateRange) {
      page = 1;
      orders.clear();
      hasMore = true;
      _dateRange = range;
    }

    if (!hasMore) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final res = await _repo.getAllOrders(
        page: page,
        limit: _limit,
        startDate: _dateRange?.start,
        endDate: _dateRange?.end,
      );

      final fetched = res.orders ?? [];
      orders.addAll(fetched);
      hasMore = fetched.length == _limit;
      page++;
    } catch (e) {
      error = "Failed to load orders";
      debugPrint(e.toString());
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> applyDateRange(DateTimeRange? range) async {
    await fetchOrders(refresh: true, range: range);
  }

  Future<void> clearDateRange() async {
    await fetchOrders(refresh: true, range: null);
  }
}
