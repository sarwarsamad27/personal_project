import 'dart:developer';

import 'package:new_brand/models/orders/getDeliveredOrder_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class GetDeliveredOrderRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetDeliveredOrder;

  Future<GetDeliveredOrderModel> getDeliveredOrder({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await apiServices.getApi(
      "$apiUrl?page=$page&limit=$limit",
    );
    log("Get dispatched Orders Response: $response");
    return GetDeliveredOrderModel.fromJson(response);
  }
}
