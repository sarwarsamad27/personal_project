import 'package:new_brand/models/productModel/getProductCategoryWise_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class GetProductCategoryWiseRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetProduct;

  /// Delete category by Id
  Future<GetProductCategoryWiseModel> getProductCategoryWise({
    required String categoryId,
    required String token,
  }) async {
    try {
      final url = "$apiUrl?categoryId=$categoryId";

      final response = await apiServices.getApi(url);

      return GetProductCategoryWiseModel.fromJson(response);
    } catch (e) {
      return GetProductCategoryWiseModel(message: "Error: $e");
    }
  }
}
