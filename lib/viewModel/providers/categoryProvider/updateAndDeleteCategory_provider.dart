import 'dart:io';
import 'package:flutter/material.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/viewModel/repository/categoryRepository/deleteCategory_repository.dart';
import 'package:new_brand/viewModel/repository/categoryRepository/updateCategory_repository.dart';

class UpdateDeleteCategoryProvider with ChangeNotifier {
  final UpdateCategoryRepository updateRepo = UpdateCategoryRepository();
  final DeleteCategoryRepository deleteRepo = DeleteCategoryRepository();

  bool isLoading = false;
  bool isDeleting = false;

  Future<bool> updateCategory({
    required String categoryId,
    String? name,
    File? image,
  }) async {
    isLoading = true;
    notifyListeners();

    final token = await LocalStorage.getToken();
    final response = await updateRepo.updateCategory(
      categoryId: categoryId,
      name: name,
      image: image,
      token: token ?? "",
    );

    isLoading = false;
    notifyListeners();

    return response.category != null;
  }

  Future<bool> deleteCategory({required String categoryId}) async {
    isDeleting = true;
    notifyListeners();

    final token = await LocalStorage.getToken();
    final response = await deleteRepo.deleteCategory(categoryId: categoryId, token: token ?? "");

    isDeleting = false;
    notifyListeners();

    return response.message != null;
  }
}
