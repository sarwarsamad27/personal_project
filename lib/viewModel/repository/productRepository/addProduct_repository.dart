import 'dart:io';
import 'package:new_brand/models/productModel/addProduct_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class AddProductRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  /// Add product with optional multiple images
 Future<AddProductModel> addProduct({
    required String token,
    required String categoryId,
    required String name,
    String? description,
    List<File>? images,
    int? beforePrice,
    int? afterPrice,
    List<String>? size,
    List<String>? color,
    int? quantity,        // ✅ stock ki jagah quantity
    int? weightInGrams,
  }) async {
    try {
      final fields = <String, String>{
        'categoryId': categoryId,
        'name': name,
        if (description != null) 'description': description,
        if (beforePrice != null) 'beforeDiscountPrice': beforePrice.toString(),
        if (afterPrice != null) 'afterDiscountPrice': afterPrice.toString(),
        if (size != null && size.isNotEmpty) 'size': size.join(','),
        if (color != null && color.isNotEmpty) 'color': color.join(','),
        if (quantity != null) 'quantity': quantity.toString(),          // ✅
        if (weightInGrams != null) 'weightInGrams': weightInGrams.toString(),
      };

      final response = await apiServices.postMultipartApi(
        Global.CreateProduct,
        fields,
        images ?? [],
        fileFieldName: "images",
      );
      return AddProductModel.fromJson(response);
    } catch (e) {
      return AddProductModel(message: "Error: $e");
    }
  }
}
