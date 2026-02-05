import 'package:flutter/material.dart';
import 'package:new_brand/models/productModel/getSingleProduct_model.dart';
import 'package:new_brand/viewModel/repository/productRepository/getSingleProduct_repository.dart';

class GetSingleProductProvider with ChangeNotifier {
  final GetSingleProductRepository repo = GetSingleProductRepository();

  bool isLoading = false;
  GetSingleProductModel? productData;

  // UI States
  bool showAllReviews = false;
  Set<String> repliedReviews = {};
  Map<String, bool> showReplyButton = {};

  void toggleShowAllReviews() {
    showAllReviews = !showAllReviews;
    notifyListeners();
  }

  void markAsReplied(String reviewId) {
    repliedReviews.add(reviewId);
    showReplyButton[reviewId] = false;
    notifyListeners();
  }

  void setShowReplyButton(String reviewId, bool show) {
    showReplyButton[reviewId] = show;
    notifyListeners();
  }

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

      // Initialize showReplyButton for new data
      if (productData?.reviews != null) {
        for (var review in productData!.reviews!) {
          if (review.sId != null) {
            showReplyButton.putIfAbsent(review.sId!, () => true);
          }
        }
      }
    } catch (e) {
      productData = GetSingleProductModel(message: e.toString());
    }

    isLoading = false;
    notifyListeners();
  }
}
