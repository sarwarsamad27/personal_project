import 'package:new_brand/models/auth/updatePassword_model.dart';
import 'package:new_brand/network/base_api_services.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class UpdatePasswordRepository {
  final BaseApiServices apiService = NetworkApiServices();
  final String apiUrl = Global.UpdatePassword;

  Future<UpdatePasswordModel> updatePassword(String email, String newPassword) async {
    try {
      final response = await apiService.postApi(apiUrl, {
        "email": email,
        "newPassword": newPassword,
      });
      print(response);
      return UpdatePasswordModel.fromJson(response);
    } catch (e) {
      return UpdatePasswordModel(message: "Error occurred: $e");
    }
  }
}
