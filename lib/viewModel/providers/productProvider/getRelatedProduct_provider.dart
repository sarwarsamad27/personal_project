import 'package:flutter/material.dart';
import 'package:new_brand/models/productModel/relatedProduct_model.dart';
import 'package:new_brand/viewModel/repository/productRepository/getRelatedProduct_repository.dart';

class GetRelatedProductProvider with ChangeNotifier {
  final GetRelatedProductRepository repo = GetRelatedProductRepository();

  bool isLoading = false;
  RelatedProductModel? productData;
  Future<void> fetchRelatedProducts({
    required String token,
    required String categoryId,
    required String productId,
  }) async {
    isLoading = true;
    notifyListeners();
    

    try {
      final response = await repo.getRelatedProduct(
        categoryId: categoryId,
        token: token,
         productId: productId,
      );

      productData = response;
    } catch (e) {
      productData = RelatedProductModel(message: e.toString());
    }

    isLoading = false;
    notifyListeners();
  }
}
