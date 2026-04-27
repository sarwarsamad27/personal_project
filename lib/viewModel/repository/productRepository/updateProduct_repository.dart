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
    required List<String> keepImages,
    required List<String> deleteImages,
    required int quantity,       // ✅ stock ki jagah quantity
    required int weightInGrams,  // ✅ weight bhi
    required List<File> images,
  }) async {
    try {
      final url = Global.UpdateSingleProduct;

      Map<String, dynamic> body = {
        'productId': productId,
        'name': name,
        'description': description,
        'afterDiscountPrice': afterDiscountPrice,
        'beforeDiscountPrice': beforeDiscountPrice,
        'size': size.join(','),
        'color': color.join(','),
        'quantity': quantity.toString(),          // ✅
        'weightInGrams': weightInGrams.toString(), // ✅
        'keepImages': keepImages.join(','),
        'deleteImages': deleteImages.join(','),
      };

      print("UPDATE BODY => $body");
      print("NEW FILES => ${images.map((e) => e.path).toList()}");

      final response = await apiServices.putMultiPart(
        url: url,
        fields: body.map((key, value) => MapEntry(key, value.toString())),
        files: images,
        fileFieldName: "images",
      );

      print("UPDATE RESPONSE => $response");
      return UpdateProductModel.fromJson(response);
    } catch (e) {
      return UpdateProductModel(message: "Error: $e");
    }
  }
}