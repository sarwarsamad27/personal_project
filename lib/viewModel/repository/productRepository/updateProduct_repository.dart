import 'dart:io';
import 'package:new_brand/models/productModel/editProduct_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class UpdateProductRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  Future<UpdateProductModel> updateProduct({
    required String productId,
    required String token,
    required String name,
    required String description,
    required int afterDiscountPrice,
    required int beforeDiscountPrice,
    required List<String> size,
    required List<String> color,
    required int stock,
    required List<File> images,
  }) async {
    try {
      final url = Global.UpdateSingleProduct;

      // Multipart request for images
      Map<String, dynamic> body = {
        'productId': productId,
        'name': name,
        'description': description,
        'afterDiscountPrice': afterDiscountPrice,
        'beforeDiscountPrice': beforeDiscountPrice,
        'size': size.join(','),
        'color': color.join(','),
        'stock': stock,
      };
      print(body);
      final response = await apiServices.putMultiPart(
        url: url,
        fields: body.map((key, value) => MapEntry(key, value.toString())),
        files: images,
        fileFieldName: "images",
      );
      print(response);

      return UpdateProductModel.fromJson(response);
    } catch (e) {
      return UpdateProductModel(message: "Error: $e");
    }
  }
}
