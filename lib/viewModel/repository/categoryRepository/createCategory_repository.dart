import 'dart:io';
import 'package:new_brand/models/categoryModel/createCategory_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class CreateCategoryRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.CreateCategory;

  Future<CreateCategoryModel> createCategory({
    required String name,
    required String token,
    

    File? image,
  }) async {
    try {
      final fields = {
        "name": name,
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
      return CreateCategoryModel.fromJson(response);
    } catch (e) {
      return CreateCategoryModel(message: "Error: $e");
    }
  }
}
