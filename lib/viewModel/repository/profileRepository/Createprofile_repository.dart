import 'dart:io';
import 'package:new_brand/models/profile/createProfile_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class ProfileRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.CreateProfile;

  Future<CreateProfileModel> createProfile({
    required String name,
    required String token,
    required String email,
    required String phone,
    required String address,
    required String description,

    File? image,
  }) async {
    try {
      final fields = {
        "name": name,
       
        "email": email,
        "phone": phone,
        "address": address,
        "description": description,
      };

      final images = <File>[];
      if (image != null) images.add(image);

      final response = await apiServices.postSingleImageApi(
        apiUrl,
        fields,
       image,
        fileFieldName: "image", 
      );
      
      print('+ ${response}');
      return CreateProfileModel.fromJson(response);
    } catch (e) {
      return CreateProfileModel(message: "Error: $e");
    }
  }
}
