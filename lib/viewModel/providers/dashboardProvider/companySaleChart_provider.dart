import 'package:flutter/material.dart';
import 'package:new_brand/models/dashboard/companySaleChart_model.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/viewModel/repository/dashboardRepository/companySaleChart_repository.dart';

class CompanySalesChartProvider with ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  CompanySalesChartModel? _chartData;
  CompanySalesChartModel? get chartData => _chartData;

  String _selectedType = "weekly";
  String get selectedType => _selectedType;

  final GetCompanySalesChartRepository repository =
      GetCompanySalesChartRepository();

  Future<void> getChartData({
    required String type,
  }) async {
    _selectedType = type;
    _loading = true;
    notifyListeners();
final token = await LocalStorage.getToken();
    try {
      _chartData = await repository.getCompanySalesChart(
        type: type,
        token: token ?? '',
      );
    } catch (_) {}

    _loading = false;
    notifyListeners();
  }
}
