import 'package:flutter/material.dart';
import 'package:new_brand/models/dashboard/dashboard_model.dart';
import 'package:new_brand/viewModel/repository/dashboardRepository/dashboard_repository.dart';

class DashboardProvider with ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  DashboardDataModel? _dashboardData;
  DashboardDataModel? get dashboardData => _dashboardData;

  bool _fetched = false; 

  final GetDashboardRepository repository = GetDashboardRepository();

  Future<void> getDashboardDataOnce({bool refresh = false}) async {
    if (_fetched && !refresh) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboardData = await repository.getDashboardData();
      _fetched = true;
    } catch (e) {
      _error = "Failed to load dashboard data";
    }

    _loading = false;
    notifyListeners();
  }

  void clearDashboardCache() {
    _fetched = false;
    _dashboardData = null;
    notifyListeners();
  }
}
