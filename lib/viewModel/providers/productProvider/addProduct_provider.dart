import 'dart:io';
import 'package:flutter/material.dart';
import 'package:new_brand/models/productModel/addProduct_model.dart';
import 'package:new_brand/viewModel/repository/productRepository/addProduct_repository.dart';

class AddProductProvider with ChangeNotifier {
  final AddProductRepository repository = AddProductRepository();

  bool isLoading = false;
  AddProductModel? productResponse;

  Future<void> addProduct({
    required final token,
    required String categoryId,
    required String name,
    String? description,
    List<File>? images,
    int? beforePrice,
    int? afterPrice,
    List<String>? size,
    List<String>? color,
    int? stock,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await repository.addProduct(
        token: token,
       
        categoryId: categoryId,
        name: name,
        description: description,
        images: images,
        beforePrice: beforePrice,
        afterPrice: afterPrice,
        size: size,
        color: color,
        stock: stock,
      );

      isLoading = false;
      productResponse = response;
      notifyListeners();

      if (response.product != null) {
        onSuccess();
      } else {
        onError(response.message ?? "Something went wrong");
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      onError(e.toString());
    }
  }
}
