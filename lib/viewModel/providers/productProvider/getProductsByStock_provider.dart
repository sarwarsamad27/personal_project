import 'package:flutter/material.dart';
import 'package:new_brand/models/productModel/getProductCategoryWise_model.dart';
import 'package:new_brand/viewModel/repository/productRepository/getProductsByStock_repository.dart';

class GetProductsByStockProvider extends ChangeNotifier {
  final GetProductsByStockRepository _repo = GetProductsByStockRepository();

  static const int _limit = 20;

  bool isLoading = false;
  String? error;
  List<Products> products = [];
  int page = 1;
  bool hasMore = true;

  // The list is scoped to whichever stock status it was last fetched for —
  // switching status (low <-> out) resets the same way `refresh` does,
  // instead of appending mismatched pages onto the previous filter's list.
  String? _stockStatus;

  Future<void> fetchProducts({
    required String stockStatus,
    bool refresh = false,
  }) async {
    if (isLoading) return;

    if (refresh || stockStatus != _stockStatus) {
      page = 1;
      products.clear();
      hasMore = true;
      _stockStatus = stockStatus;
    }

    if (!hasMore) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final res = await _repo.getProductsByStock(
        stockStatus: stockStatus,
        page: page,
        limit: _limit,
      );

      final fetched = res.products ?? [];
      products.addAll(fetched);
      hasMore = fetched.length == _limit;
      page++;
    } catch (e) {
      error = "Failed to load products";
      debugPrint(e.toString());
    }

    isLoading = false;
    notifyListeners();
  }
}
