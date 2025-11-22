import 'package:new_brand/models/categoryModel/updateCategory_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class DeleteCategoryRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  /// Delete category by Id
  Future<UpdateCategoryModel> deleteCategory({
    required String categoryId,
    required String token,
  }) async {
    try {
      final url = "${Global.DeleteCategory}?categoryId=$categoryId";

      final response = await apiServices.deleteApi(url);

      return UpdateCategoryModel.fromJson(response);
    } catch (e) {
      return UpdateCategoryModel(message: "Error: $e");
    }
  }
}
