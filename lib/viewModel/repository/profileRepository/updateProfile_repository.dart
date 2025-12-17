import 'dart:io';
import 'package:new_brand/models/profile/updateProfile_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class UpdateProfileRepository {
  final NetworkApiServices api = NetworkApiServices();

  Future<UpdateProfileModel> updateProfile({
    required String token,
    required Map<String, String> fields,
    File? image,
  }) async {
    try {
      final response = await api.putApi(
        Global.UpdateProfile, 
        fields,
        image: image,
        fileFieldName: "image" ,
      );

      return UpdateProfileModel.fromJson(response);

    } catch (e) {
      return UpdateProfileModel(message: "Error: $e");
    }
  }
}
