import 'package:flutter/material.dart';
import 'package:new_brand/models/productModel/getSingleProduct_model.dart';
import 'package:new_brand/viewModel/repository/productRepository/getSingleProduct_repository.dart';

class GetSingleProductProvider with ChangeNotifier {
  final GetSingleProductRepository repo = GetSingleProductRepository();

  bool isLoading = false;
  GetSingleProductModel? productData;

  Future<void> fetchSingleProducts({
    required String token,
    required String categoryId,
    required String productId,
  }) async {
    isLoading = true;
    notifyListeners();
    

    try {
      final response = await repo.getSingleProduct(
        categoryId: categoryId,
        token: token,
         productId: productId,
      );

      productData = response;
    } catch (e) {
      productData = GetSingleProductModel(message: e.toString());
    }

    isLoading = false;
    notifyListeners();
  }
}
