import 'dart:developer';

import 'package:new_brand/models/orders/getDispatchedOrder_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class GetDispatchedOrderRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetDispatchedOrder;

  Future<GetDispatchedOrderModel> getDispatchedOrder({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await apiServices.getApi(
      "$apiUrl?page=$page&limit=$limit",
    );
    log("Get dispatched Orders Response: $response");
    return GetDispatchedOrderModel.fromJson(response);
  }
}
