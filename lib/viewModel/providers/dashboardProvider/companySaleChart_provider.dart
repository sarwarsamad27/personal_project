import 'package:flutter/material.dart';
import 'package:new_brand/models/dashboard/companySaleChart_model.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/viewModel/repository/dashboardRepository/companySaleChart_repository.dart';

class CompanySalesChartProvider with ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  // ✅ selected type moved here (UI setState remove)
  String _selectedType = "weekly";
  String get selectedType => _selectedType;

  // ✅ cache per type
  final Map<String, CompanySalesChartModel> _cache = {};

  // current data based on selectedType
  CompanySalesChartModel? _chartData;
  CompanySalesChartModel? get chartData => _chartData;

  final GetCompanySalesChartRepository repository =
      GetCompanySalesChartRepository();

  /// ✅ Will NOT hit API again if already cached (unless refresh=true)
  Future<void> getChartData({
    required String type,
    bool refresh = false,
  }) async {
    final normalized = type.toLowerCase();
    _selectedType = normalized;

    // ✅ serve from cache
    if (!refresh && _cache.containsKey(normalized)) {
      _chartData = _cache[normalized];
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    final token = await LocalStorage.getToken();

    try {
      final res = await repository.getCompanySalesChart(
        type: normalized,
        token: token ?? '',
      );

      _cache[normalized] = res;
      _chartData = res;
    } catch (e) {
      _error = "Failed to load chart";
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// ✅ Optional: clear cache (logout etc.)
  void clearCache() {
    _cache.clear();
    _chartData = null;
    _selectedType = "weekly";
    notifyListeners();
  }
}
