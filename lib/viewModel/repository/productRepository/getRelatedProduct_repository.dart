import 'package:new_brand/models/productModel/relatedProduct_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class GetRelatedProductRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetRelatedProduct;

  /// Delete category by Id
  Future<RelatedProductModel> getRelatedProduct({
    required String categoryId,
    required String productId,
    required String token,
  }) async {
    try {
      final url = "$apiUrl?productId=$productId&categoryId=$categoryId";

      final response = await apiServices.getApi(url);

      return RelatedProductModel.fromJson(response);
    } catch (e) {
      return RelatedProductModel(message: "Error: $e");
    }
  }
}
