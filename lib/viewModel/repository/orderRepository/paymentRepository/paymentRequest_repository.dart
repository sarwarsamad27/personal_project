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

      final response = await apiServices.postApi(
        url,
        ({
          "name": name,
          "phone": phone,
          "amount": amount,
          "method": method,
          if (bankName != null) "bankName": bankName,
          if (accountNumber != null) "accountNumber": accountNumber,
          if (iban != null) "iban": iban,
        }),
        // The caller (withdraw sheet) inspects the returned message itself —
        // e.g. to show a bad mobile-number format inline under that field
        // instead of as a generic global toast.
        suppressErrorToast: true,
      );
      print(response);

      return PaymentRequestModel.fromJson(response);
    } catch (e) {
      return PaymentRequestModel(message: "Error: $e");
    }
  }
}
