import 'package:new_brand/models/productModel/deleteProduct_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class DeleteProductRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  /// Delete category by Id
  Future<DeleteProductModel> deleteProduct({
    required String productId,
    required String token,
  }) async {
    try {
      final url = "${Global.DeleteSingleProduct}?productId=$productId";

      final response = await apiServices.deleteApi(url);

      return DeleteProductModel.fromJson(response);
    } catch (e) {
      return DeleteProductModel(message: "Error: $e");
    }
  }
}
