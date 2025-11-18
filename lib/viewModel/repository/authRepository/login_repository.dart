import 'package:new_brand/models/auth/login_model.dart';
import 'package:new_brand/network/base_api_services.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class LoginRepository {
  final BaseApiServices apiService = NetworkApiServices();
  final String apiUrl = Global.Login;

  Future<LoginModel> login(String email, String password) async {
    try {
      final response = await apiService.postApi(apiUrl, {
        "email": email,
        "password": password,
      });
      print(response);
      return LoginModel.fromJson(response);
    } catch (e) {
      return LoginModel(message: "Error occurred: $e");
    }
  }
}
