import 'package:flutter/material.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class AcceptOrderProvider with ChangeNotifier {
  final NetworkApiServices _api = NetworkApiServices();

  bool isLoading = false;
  bool isRetrying = false;
  String? trackNumber;
  String? slipLink;
  String? errorMessage;
  String? leopardsError; // Leopards booking failed but order accepted
  bool isAccepted = false;
  String? updatedStatus;

  Future<bool> acceptOrder({
    required String token,
    required String orderId,
  }) async {
    isLoading = true;
    errorMessage = null;
    leopardsError = null;
    notifyListeners();

    try {
      final response = await _api.postApi(
        Global.AcceptOrder,
        {'orderId': orderId},
      );

      trackNumber   = response['trackNumber'];
      slipLink      = response['slipLink'];
      leopardsError = response['leopardsError'];

      if (response['order'] != null) {
        updatedStatus = response['order']['status'];
      }

      isLoading = false;

      if (response['order'] != null) {
        isAccepted = true;
        notifyListeners();
        return true;
      } else {
        errorMessage = response['message'] ?? "Something went wrong";
        notifyListeners();
        return false;
      }
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Retry Leopards booking for an accepted order that failed the first time
  Future<bool> retryLeopardsBooking({required String orderId}) async {
    isRetrying = true;
    leopardsError = null;
    notifyListeners();

    try {
      final response = await _api.postApi(
        Global.RetryLeopardsBooking,
        {'orderId': orderId},
      );

      isRetrying = false;

      if (response['trackNumber'] != null) {
        trackNumber   = response['trackNumber'];
        slipLink      = response['slipLink'];
        leopardsError = null;
        notifyListeners();
        return true;
      } else {
        leopardsError = response['leopardsError'] ?? response['message'] ?? "Booking failed";
        notifyListeners();
        return false;
      }
    } catch (e) {
      isRetrying = false;
      leopardsError = e.toString();
      notifyListeners();
      return false;
    }
  }

  void reset() {
    trackNumber   = null;
    slipLink      = null;
    errorMessage  = null;
    leopardsError = null;
    isAccepted    = false;
    isRetrying    = false;
    updatedStatus = null;
    notifyListeners();
  }
}
