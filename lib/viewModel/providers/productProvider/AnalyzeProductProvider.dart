import 'dart:io';
import 'package:flutter/material.dart';
import 'package:new_brand/models/productModel/AnalyzeProductModel.dart';
import 'package:new_brand/viewModel/repository/productRepository/analyzeProduct_repository.dart';

class AnalyzeProductProvider with ChangeNotifier {
  final AnalyzeProductRepository _repository = AnalyzeProductRepository();

  bool isAnalyzing = false;
  AnalyzeProductModel? analyzeResult;

  Future<void> analyzeImage({
    required String token,
    required File image,
    required Function(String name, String description) onSuccess,
    required Function(String error) onError,
  }) async {
    isAnalyzing = true;
    notifyListeners();

    try {
      final result = await _repository.analyzeImage(
        token: token,
        image: image,
      );

      isAnalyzing = false;
      analyzeResult = result;
      notifyListeners();

      if (result.name != null && result.description != null) {
        onSuccess(result.name!, result.description!);
      } else {
        onError(result.message ?? 'Could not analyze image');
      }
    } catch (e) {
      isAnalyzing = false;
      notifyListeners();
      onError(e.toString());
    }
  }

  void reset() {
    isAnalyzing = false;
    analyzeResult = null;
    notifyListeners();
  }
}