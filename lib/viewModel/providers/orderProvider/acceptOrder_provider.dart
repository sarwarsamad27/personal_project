import 'package:flutter/material.dart';
import 'package:new_brand/viewModel/repository/orderRepository/acceptOrder_repository.dart';

class AcceptOrderProvider with ChangeNotifier {
  final AcceptOrderRepository _repo = AcceptOrderRepository();

  bool isLoading = false;
  String? trackNumber;
  String? slipLink;
  String? errorMessage;
  bool isAccepted = false;
  String? updatedStatus; // ✅ NEW

  Future<bool> acceptOrder({
    required String token,
    required String orderId,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _repo.acceptOrder(
        token: token,
        orderId: orderId,
      );

      trackNumber = response['trackNumber'];
      slipLink = response['slipLink'];

      // ✅ Updated status save karo
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

  void reset() {
    trackNumber = null;
    slipLink = null;
    errorMessage = null;
    isAccepted = false;
    updatedStatus = null;
    notifyListeners();
  }
}