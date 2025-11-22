import 'package:flutter/material.dart';
import 'package:new_brand/models/productModel/deleteProduct_model.dart';
import 'package:new_brand/viewModel/repository/productRepository/deleteProduct_repository.dart';

class DeleteProductProvider extends ChangeNotifier {
  final DeleteProductRepository repo = DeleteProductRepository();
  DeleteProductModel? deleteProductModel;
  bool isLoading = false;

  Future<void> deleteProduct({
    required String productId,
    required String token,
  }) async {
    isLoading = true;
    notifyListeners();

    deleteProductModel = await repo.deleteProduct(
      productId: productId,
      token: token,
    );

    isLoading = false;
    notifyListeners();
  }
}
