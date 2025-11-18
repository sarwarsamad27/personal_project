import 'package:new_brand/models/auth/signUp_model.dart';
import 'package:new_brand/network/base_api_services.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class SignUpRepository {
  final BaseApiServices apiService = NetworkApiServices();
  final String apiUrl = Global.SignUp;

  Future<SignUpModel> signUp(String email, String password) async {
    try {
      final response = await apiService.postApi(apiUrl, {
        "email": email,
        "password": password,
      });

      return SignUpModel.fromJson(response);
    } catch (e) {
      return SignUpModel(message: "Error occurred: $e");
    }
  }
}
