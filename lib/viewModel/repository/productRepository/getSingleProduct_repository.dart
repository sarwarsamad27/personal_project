import 'package:new_brand/models/productModel/getSingleProduct_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class GetSingleProductRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetSingleProduct;

  /// Delete category by Id
  Future<GetSingleProductModel> getSingleProduct({
    required String categoryId,
    required String productId,
    required String token,
  }) async {
    try {
      final url = "$apiUrl/?productId=$productId&categoryId=$categoryId";

      final response = await apiServices.getApi(url);

      return GetSingleProductModel.fromJson(response);
    } catch (e) {
      return GetSingleProductModel(message: "Error: $e");
    }
  }
}
