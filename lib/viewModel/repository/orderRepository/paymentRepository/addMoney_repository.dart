import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class AddMoneyRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  Future<Map<String, dynamic>> initiateJazzcashCredit({
    required String phone,
    required String amount,
  }) async {
    final response = await apiServices.postApi(
      Global.AddMoneyInitiate,
      {
        'phone': phone,
        'amount': amount,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> confirmJazzcashCredit({
    required String txnRefNo,
  }) async {
    final response = await apiServices.postApi(
      Global.AddMoneyConfirm,
      {
        'txnRefNo': txnRefNo,
      },
    );
    return response;
  }
}
