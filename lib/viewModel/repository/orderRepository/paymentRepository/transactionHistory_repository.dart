import 'dart:developer';

import 'package:new_brand/models/orders/payment/transactionhistory_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class GetTransactionRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.TransactionHistory;

  Future<TransactionHistoryModel> getTransaction({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await apiServices.getApi(
      "$apiUrl?page=$page&limit=$limit",
    );
    log("Get transaction Response: $response");
    return TransactionHistoryModel.fromJson(response);
  }
}
