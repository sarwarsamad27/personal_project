  import 'package:flutter/material.dart';
  import 'package:new_brand/models/productModel/getProductCategoryWise_model.dart';
  import 'package:new_brand/viewModel/repository/productRepository/getProductCategoryWise_repository.dart';

  class GetProductCategoryWiseProvider with ChangeNotifier {
    final GetProductCategoryWiseRepository repo = GetProductCategoryWiseRepository();

    bool isLoading = false;
    GetProductCategoryWiseModel? productData;

    Future<void> fetchProducts({
      required String token,
      required String categoryId,
    }) async {
      isLoading = true;
      notifyListeners();
      

      try {
        final response = await repo.getProductCategoryWise(
          categoryId: categoryId,
          token: token,
        );

        productData = response;
      } catch (e) {
        productData = GetProductCategoryWiseModel(message: e.toString());
      }

      isLoading = false;
      notifyListeners();
    }
  }
