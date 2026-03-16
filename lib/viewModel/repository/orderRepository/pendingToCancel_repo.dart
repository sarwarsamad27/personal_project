import 'package:new_brand/models/orders/pendingToCancel_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class CancelOrderRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  Future<CancelOrderModel> cancelOrder({
    required String orderId,
    required String token,
    String? reason,
  }) async {
    try {
      final url = Global.PendingToCancelled; // ✅ add this in global.dart

      final response = await apiServices.postApi(url, {
        'orderId': orderId,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      });

      print("Cancel Order Response: $response");
      return CancelOrderModel.fromJson(response);
    } catch (e) {
      return CancelOrderModel(message: "Error: $e");
    }
  }
}
