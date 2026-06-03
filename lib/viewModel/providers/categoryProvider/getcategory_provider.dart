import 'package:flutter/material.dart';
import 'package:new_brand/models/categoryModel/getCategory_model.dart';
import 'package:new_brand/viewModel/repository/categoryRepository/getCategory_repository.dart';

class GetCategoryProvider with ChangeNotifier {
  final GetCategoryRepository _repo = GetCategoryRepository();

  bool isLoading = false;
  bool isFetched = false;
  GetCategoryModel? categoryData;

  Future<void> getCategories({bool forceRefresh = false}) async {
    if (isFetched && !forceRefresh) return;

    try {
      isLoading = true;
      notifyListeners();

      final response = await _repo.getCategory();
      categoryData = response;
      isFetched = true;
    } catch (e) {
      print("Category Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Socket Update Methods ──

  void updateCategoryInList(Categories updatedCategory) {
    if (categoryData?.categories == null) return;
    final index = categoryData!.categories!.indexWhere(
      (c) => c.sId == updatedCategory.sId,
    );
    if (index != -1) {
      categoryData!.categories![index] = updatedCategory;
      notifyListeners();
    }
  }

  void deleteCategoryFromList(String categoryId) {
    if (categoryData?.categories == null) return;
    categoryData!.categories!.removeWhere((c) => c.sId == categoryId);
    notifyListeners();
  }
}
