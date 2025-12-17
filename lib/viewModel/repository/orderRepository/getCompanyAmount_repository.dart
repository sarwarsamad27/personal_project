import 'dart:developer';

import 'package:new_brand/models/orders/getCompanyAmount_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class GetCompanyAmountRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetCompanyAmount;

  Future<GetCompanyAmountModel> getCompanyAmount() async {
    final response = await apiServices.getApi(
      apiUrl,
    );
    log("Get dispatched Orders Response: $response");
    return GetCompanyAmountModel.fromJson(response);
  }
}
