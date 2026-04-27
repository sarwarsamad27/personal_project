import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class AcceptOrderRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  Future<Map<String, dynamic>> acceptOrder({
    required String token,
    required String orderId,
  }) async {
    try {
      final response = await apiServices.postApi(
        Global.AcceptOrder,
        {'orderId': orderId},
      );
      return response;
    } catch (e) {
      return {'message': 'Error: $e'};
    }
  }
}