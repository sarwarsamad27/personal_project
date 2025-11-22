import 'dart:io';
import 'package:flutter/material.dart';
import 'package:new_brand/models/productModel/editProduct_model.dart';
import 'package:new_brand/viewModel/repository/productRepository/updateProduct_repository.dart';

class UpdateProductProvider with ChangeNotifier {
  final UpdateProductRepository repo = UpdateProductRepository();

  bool isLoading = false;
  UpdateProductModel? updateProductModel;

  Future<void> updateProduct({
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
    isLoading = true;
    notifyListeners();

    try {
      updateProductModel = await repo.updateProduct(
        productId: productId,
        token: token,
        name: name,
        description: description,
        afterDiscountPrice: afterDiscountPrice,
        beforeDiscountPrice: beforeDiscountPrice,
        size: size,
        color: color,
        stock: stock,
        images: images,
      );
    } catch (e) {
      updateProductModel = UpdateProductModel(message: e.toString());
    }

    isLoading = false;
    notifyListeners();
  }
}
