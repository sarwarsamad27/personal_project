import 'package:new_brand/models/orders/payment/paymentRequest_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class PaymentRequestRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  Future<PaymentRequestModel> paymentRequest({
    required String name,
    required String phone,
    required String amount,
    required String method,
    String? bankName,
    String? accountNumber,
    String? iban,
    required String token,
  }) async {
    try {
      final url = Global.PaymentRequest;

      final response = await apiServices.postApi(url, ({
        "name": name,
        "phone": phone,
        "amount": amount,
        "method": method,
        if (bankName != null) "bankName": bankName,
        if (accountNumber != null) "accountNumber": accountNumber,
        if (iban != null) "iban": iban,
      }));
      print(response);

      return PaymentRequestModel.fromJson(response);
    } catch (e) {
      return PaymentRequestModel(message: "Error: $e");
    }
  }
}
