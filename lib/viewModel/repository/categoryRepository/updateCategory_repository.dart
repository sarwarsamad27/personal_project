import 'dart:io';
import 'package:new_brand/models/categoryModel/updateCategory_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class UpdateCategoryRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  /// Update Category (name + optional image)
  Future<UpdateCategoryModel> updateCategory({
    required String token,
    required String categoryId,
    String? name,
    File? image,
  }) async {
    try {
      final fields = <String, String>{
        'categoryId': categoryId,
      };
      if (name != null) fields['name'] = name;

      final response = await apiServices.putApi(
        Global.EditCategory,
        fields,
        fileFieldName: 'image',
      );

      return UpdateCategoryModel.fromJson(response);
    } catch (e) {
      return UpdateCategoryModel(message: "Error: $e");
    }
  }
}
