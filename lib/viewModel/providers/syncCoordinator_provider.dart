import 'package:flutter/material.dart';
import 'package:new_brand/resources/offline_queue.dart';
import 'package:new_brand/viewModel/providers/categoryProvider/createCategory_provider.dart';
import 'package:new_brand/viewModel/providers/productProvider/addProduct_provider.dart';

/// Drives the whole offline-queue sync as one sequential, awaited run so
/// screens never see a half-synced state. Categories are synced first so
/// any product that was queued against an offline-pending category gets its
/// categoryId remapped to the real server id before that product syncs.
///
/// Screens watch [isSyncing]/[percent] for a progress indicator and
/// [syncVersion] to know when to refresh their own data after a run finishes.
class SyncCoordinator with ChangeNotifier {
  final CreateCategoryProvider categoryProvider;
  final AddProductProvider productProvider;

  SyncCoordinator({
    required this.categoryProvider,
    required this.productProvider,
  });

  bool isSyncing = false;
  int total = 0;
  int completed = 0;

  /// Bumped after every completed run — screens compare this against a
  /// locally-remembered value to know whether to refresh.
  int syncVersion = 0;

  /// local category id -> real server id, from the most recent run. Screens
  /// open on a still-pending category check this to follow it once synced.
  Map<String, String> lastIdMap = {};

  double get percent => total == 0 ? 1.0 : completed / total;

  Future<void> syncAll() async {
    if (isSyncing) return;

    final items = await OfflineQueue.getAll();
    if (items.isEmpty) return;

    isSyncing = true;
    total = items.length;
    completed = 0;
    notifyListeners();

    // 1) Categories first, recording local-id -> real-id for remapping.
    final categoryItems =
        items.where((e) => e['type'] == 'add_category').toList();
    final idMap = <String, String>{};
    for (final item in categoryItems) {
      final localId = item['id'] as String;
      final realId = await categoryProvider.syncOne(item);
      if (realId != null) idMap[localId] = realId;
      completed++;
      notifyListeners();
    }

    lastIdMap = idMap;
    if (idMap.isNotEmpty) {
      await OfflineQueue.remapProductCategoryIds(idMap);
    }

    // 2) Products — re-read the queue since remap rewrote categoryId in place.
    final productItems = (await OfflineQueue.getAll())
        .where((e) => e['type'] == 'add_product')
        .toList();
    for (final item in productItems) {
      await productProvider.syncOne(item);
      completed++;
      notifyListeners();
    }

    isSyncing = false;
    syncVersion++;
    notifyListeners();
  }
}
