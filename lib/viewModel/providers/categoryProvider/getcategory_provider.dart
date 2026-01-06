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
}
