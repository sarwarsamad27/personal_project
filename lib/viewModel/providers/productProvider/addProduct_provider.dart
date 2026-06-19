import 'dart:io';
import 'package:flutter/material.dart';
import 'package:new_brand/models/productModel/addProduct_model.dart';
import 'package:new_brand/resources/offline_queue.dart';
import 'package:new_brand/viewModel/providers/connectivity_provider.dart';
import 'package:new_brand/viewModel/repository/productRepository/addProduct_repository.dart';

class AddProductProvider with ChangeNotifier {
  final AddProductRepository repository = AddProductRepository();

  bool isLoading = false;
  bool isQueued = false;
  AddProductModel? productResponse;

  Future<void> addProduct({
    required final token,
    required String categoryId,
    required String name,
    String? description,
    List<File>? images,
    File? video,
    int? beforePrice,
    int? afterPrice,
    List<String>? size,
    List<String>? color,
    int? quantity,
    int? weightInGrams,
    required VoidCallback onSuccess,
    VoidCallback? onQueued,
    required Function(String) onError,
  }) async {
    isLoading = true;
    isQueued = false;
    notifyListeners();

    // Offline: copy all files to permanent storage and queue
    if (!ConnectivityProvider.online) {
      try {
        final imagePaths = <String>[];
        for (final img in (images ?? [])) {
          imagePaths.add(await OfflineQueue.copyFilePermanent(img));
        }
        String? videoPath;
        if (video != null) {
          videoPath = await OfflineQueue.copyFilePermanent(video);
        }

        await OfflineQueue.enqueue(
          type: 'add_product',
          data: {
            'categoryId': categoryId,
            'name': name,
            if (description != null) 'description': description,
            if (beforePrice != null) 'beforePrice': beforePrice,
            if (afterPrice != null) 'afterPrice': afterPrice,
            if (size != null) 'size': size,
            if (color != null) 'color': color,
            if (quantity != null) 'quantity': quantity,
            if (weightInGrams != null) 'weightInGrams': weightInGrams,
            'imagePaths': imagePaths,
            if (videoPath != null) 'videoPath': videoPath,
          },
        );
        isQueued = true;
        isLoading = false;
        notifyListeners();
        onQueued?.call();
      } catch (e) {
        isLoading = false;
        notifyListeners();
        onError(e.toString());
      }
      return;
    }

    try {
      final response = await repository.addProduct(
        token: token,
        categoryId: categoryId,
        name: name,
        description: description,
        images: images,
        video: video,
        beforePrice: beforePrice,
        afterPrice: afterPrice,
        size: size,
        color: color,
        quantity: quantity,
        weightInGrams: weightInGrams,
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

  /// Called on reconnect — submits queued products.
  Future<void> processOfflineQueue() async {
    final items = await OfflineQueue.getAll();
    final prodItems =
        items.where((e) => e['type'] == 'add_product').toList();
    if (prodItems.isEmpty) return;

    for (final item in prodItems) {
      try {
        final d = item['data'] as Map<String, dynamic>;
        final imagePaths = List<String>.from(d['imagePaths'] ?? []);
        final imageFiles = imagePaths
            .map((p) => File(p))
            .where((f) => f.existsSync())
            .toList();

        File? videoFile;
        if (d['videoPath'] != null) {
          final vf = File(d['videoPath'] as String);
          if (vf.existsSync()) videoFile = vf;
        }

        final result = await repository.addProduct(
          token: '',
          categoryId: d['categoryId'] as String,
          name: d['name'] as String,
          description: d['description'] as String?,
          images: imageFiles.isEmpty ? null : imageFiles,
          video: videoFile,
          beforePrice: (d['beforePrice'] as num?)?.toInt(),
          afterPrice: (d['afterPrice'] as num?)?.toInt(),
          size: d['size'] != null ? List<String>.from(d['size'] as List) : null,
          color:
              d['color'] != null ? List<String>.from(d['color'] as List) : null,
          quantity: (d['quantity'] as num?)?.toInt(),
          weightInGrams: (d['weightInGrams'] as num?)?.toInt(),
        );

        if (result.product != null) {
          await OfflineQueue.remove(item['id'] as String);
          for (final path in imagePaths) {
            try {
              await File(path).delete();
            } catch (_) {}
          }
          if (d['videoPath'] != null) {
            try {
              await File(d['videoPath'] as String).delete();
            } catch (_) {}
          }
        }
      } catch (_) {}
    }
  }
}
