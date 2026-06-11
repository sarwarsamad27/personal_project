import 'dart:io';
import 'package:flutter/material.dart';
import 'package:new_brand/viewModel/repository/profileRepository/AnalyzeStore_repository.dart';

class AnalyzeStoreProvider with ChangeNotifier {
  final AnalyzeStoreRepository _repository = AnalyzeStoreRepository();

  bool isAnalyzing = false;

  Future<void> generateDescription({
    required String token,
    required String name,
    required String address,
    File? image,
    String? imageUrl,
    String? prompt,
    String? previousDescription,
    required Function(String description) onSuccess,
    required Function(String error) onError,
  }) async {
    isAnalyzing = true;
    notifyListeners();

    try {
      final result = await _repository.analyzeStore(
        token: token,
        name: name,
        address: address,
        image: image,
        imageUrl: imageUrl,
        prompt: prompt,
        previousDescription: previousDescription,
      );

      isAnalyzing = false;
      notifyListeners();

      final description = result.description?.trim();
      if (description != null && description.isNotEmpty) {
        onSuccess(description);
      } else {
        onError(result.message ?? 'Could not generate description');
      }
    } catch (e) {
      isAnalyzing = false;
      notifyListeners();
      onError(e.toString());
    }
  }
}
