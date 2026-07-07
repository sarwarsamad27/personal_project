import 'package:new_brand/models/auth/verifyCode_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class VerifyCodeRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  // 💤 Firebase ID token version (restore when Blaze is enabled):
  //   required String idToken,   ->   body: {"idToken": idToken}
  Future<VerifyCodeModel> verifyCode({
    required String otp,
    required String token,
  }) async {
    try {
      final url = Global.PaymentVerifycode;

      final response = await apiServices.postApi(url, ({"otp": otp}));
      print(response);

      return VerifyCodeModel.fromJson(response);
    } catch (e) {
      return VerifyCodeModel(message: "Error: $e");
    }
  }
}
