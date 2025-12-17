

import 'dart:developer';

import 'package:new_brand/models/orders/getMyOrders_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class GetOrderRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetOrders;

  Future<GetMyOrders> getOrders({int page = 1, int limit = 10}) async {
    final response = await apiServices.getApi("$apiUrl?page=$page&limit=$limit");
    log(  "Get Orders Response: $response");
    return GetMyOrders.fromJson(response);
  }
}

