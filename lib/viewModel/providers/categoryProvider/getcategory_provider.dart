import 'package:flutter/material.dart';
import 'package:new_brand/models/categoryModel/getCategory_model.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/offline_queue.dart';
import 'package:new_brand/viewModel/repository/categoryRepository/getCategory_repository.dart';

class GetCategoryProvider with ChangeNotifier {
  final GetCategoryRepository _repo = GetCategoryRepository();

  bool isLoading = false;
  bool isFetched = false;
  GetCategoryModel? categoryData;

  /// Categories queued offline, not yet synced to the server
  List<Categories> pendingCategories = [];

  /// Server categories + still-pending offline ones, ready for the UI
  List<Categories> get displayCategories => [
        ...pendingCategories,
        ...?categoryData?.categories,
      ];

  Future<void> getCategories({bool forceRefresh = false}) async {
    if (isFetched && !forceRefresh) {
      await refreshPendingCategories();
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      final response = await _repo.getCategory();
      categoryData = response;
      isFetched = true;
    } catch (e) {
      print("Category Error: $e");
    } finally {
      await refreshPendingCategories();
      isLoading = false;
      notifyListeners();
    }
  }

  /// Rebuilds [pendingCategories] from the offline queue. Safe to call
  /// anytime (e.g. right after queuing a category, or on reconnect).
  Future<void> refreshPendingCategories() async {
    final ownerId = await LocalStorage.getCurrentAccountId();
    final items = await OfflineQueue.getForOwner(ownerId);
    pendingCategories = items
        .where((e) => e['type'] == 'add_category')
        .map((e) {
          final data = e['data'] as Map<String, dynamic>;
          return Categories(
            sId: e['id'] as String,
            name: data['name'] as String?,
            image: data['imagePath'] as String?,
            hasLowStock: false,
            hasOutOfStock: false,
          );
        })
        .toList();
    notifyListeners();
  }

  bool isPending(String? sId) => pendingCategories.any((c) => c.sId == sId);

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
