import 'package:flutter/material.dart';
import 'package:new_brand/models/productModel/getProductCategoryWise_model.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/offline_queue.dart';
import 'package:new_brand/viewModel/repository/productRepository/getProductCategoryWise_repository.dart';

class GetProductCategoryWiseProvider with ChangeNotifier {
  final GetProductCategoryWiseRepository repo =
      GetProductCategoryWiseRepository();

  bool isLoading = false;
  GetProductCategoryWiseModel? productData;

  /// Products queued offline (for the currently loaded category), not yet synced
  List<Products> pendingProducts = [];

  /// Server products + still-pending offline ones for this category, ready for the UI
  List<Products> get displayProducts => [
        ...pendingProducts,
        ...?productData?.products,
      ];

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

    await refreshPendingProducts(categoryId);

    isLoading = false;
    notifyListeners();
  }

  /// Rebuilds [pendingProducts] for [categoryId] from the offline queue. Safe
  /// to call anytime (e.g. right after queuing a product, or on reconnect).
  Future<void> refreshPendingProducts(String categoryId) async {
    final ownerId = await LocalStorage.getCurrentAccountId();
    final items = await OfflineQueue.getForOwner(ownerId);
    pendingProducts = items
        .where((e) =>
            e['type'] == 'add_product' &&
            (e['data'] as Map<String, dynamic>)['categoryId'] == categoryId)
        .map((e) {
          final data = e['data'] as Map<String, dynamic>;
          final imagePaths = List<String>.from(data['imagePaths'] ?? []);
          return Products(
            sId: e['id'] as String,
            categoryId: categoryId,
            name: data['name'] as String?,
            description: data['description'] as String?,
            images: imagePaths,
            beforeDiscountPrice: (data['beforePrice'] as num?)?.toInt(),
            afterDiscountPrice: (data['afterPrice'] as num?)?.toInt(),
            quantity: (data['quantity'] as num?)?.toInt(),
          );
        })
        .toList();
    notifyListeners();
  }

  bool isPending(String? sId) => pendingProducts.any((p) => p.sId == sId);

  // ── Socket Update Methods ──

  void updateProductInList(Products updatedProduct) {
    if (productData?.products == null) return;
    final index = productData!.products!.indexWhere(
      (p) => p.sId == updatedProduct.sId,
    );
    if (index != -1) {
      productData!.products![index] = updatedProduct;
      notifyListeners();
    }
  }

  void deleteProductFromList(String productId) {
    if (productData?.products == null) return;
    productData!.products!.removeWhere((p) => p.sId == productId);
    notifyListeners();
  }
}
