import 'package:new_brand/models/auth/verifyCode_model.dart';
import 'package:new_brand/network/base_api_services.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class VerifyCodeRepository {
  final BaseApiServices apiService = NetworkApiServices();
  final String apiUrl = Global.VerifyCode;

  Future<VerifyCodeModel> verifyCode(String email, String verificationCode) async {
    try {
      final response = await apiService.postApi(apiUrl, {
        "email": email,
        "verificationCode": verificationCode,
      });
      print(response);
      return VerifyCodeModel.fromJson(response);
    } catch (e) {
      return VerifyCodeModel(message: "Error occurred: $e");
    }
  }
}
