import 'package:flutter/material.dart';
import 'package:new_brand/models/courier/leopards_tracking_model.dart';
import 'package:new_brand/viewModel/repository/courierRepository/leopards_tracking_repository.dart';

class LeopardsTrackingProvider with ChangeNotifier {
  final LeopardsTrackingRepository _repository = LeopardsTrackingRepository();

  bool _loading = false;
  bool get loading => _loading;

  List<LeopardsTrackingModel> _history = [];
  List<LeopardsTrackingModel> get history => _history;

  Future<void> fetchTracking(String trackNumber) async {
    _loading = true;
    _history = [];
    notifyListeners();

    try {
      _history = await _repository.trackParcel(trackNumber);
    } catch (e) {
      print("❌ fetchTracking Error: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> requestPickup(String trackNumber) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await _repository.requestPickup(trackNumber);
      if (response['status'] == 1 || response['code_status'] == true) {
        // Refresh tracking to see updated status
        await fetchTracking(trackNumber);
      }
    } catch (e) {
      print("❌ requestPickup Error: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
