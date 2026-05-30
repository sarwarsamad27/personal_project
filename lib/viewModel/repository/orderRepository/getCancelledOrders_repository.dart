import 'dart:developer';
import 'package:new_brand/models/orders/getMyOrders_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class GetCancelledOrdersRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  Future<GetMyPendingOrders> getCancelledOrders({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await apiServices.getApi(
      "${Global.GetCancelledOrders}?page=$page&limit=$limit",
    );
    log("Get Cancelled Orders Response: $response");
    return GetMyPendingOrders.fromJson(response);
  }
}
