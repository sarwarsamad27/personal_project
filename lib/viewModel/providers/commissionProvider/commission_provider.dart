import 'package:flutter/material.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class CommissionProvider with ChangeNotifier {
  final NetworkApiServices _api = NetworkApiServices();

  double _commissionPercent = 10.0;
  bool _isLoading = false;
  bool _hasFetched = false;

  double get commissionPercent => _commissionPercent;
  bool get isLoading => _isLoading;
  bool get hasFetched => _hasFetched;

  Future<void> fetchCommission() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.getApi(Global.AdminGetCommission);
      if (res['commissionPercent'] != null) {
        _commissionPercent = (res['commissionPercent'] as num).toDouble();
        _hasFetched = true;
      }
    } catch (e) {
      debugPrint("❌ Failed to fetch commission: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  // Helper for manual refresh
  Future<void> refresh() => fetchCommission();
}
