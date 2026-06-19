import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_brand/models/categoryModel/createCategory_model.dart';
import 'package:new_brand/resources/offline_queue.dart';
import 'package:new_brand/viewModel/providers/connectivity_provider.dart';
import 'package:new_brand/viewModel/repository/categoryRepository/createCategory_repository.dart';

class CreateCategoryProvider with ChangeNotifier {
  final CreateCategoryRepository repository = CreateCategoryRepository();
  final TextEditingController nameController = TextEditingController();

  bool _loading = false;
  bool get loading => _loading;

  bool _queued = false;
  bool get queued => _queued;

  File? _image;
  File? get image => _image;

  CreateCategoryModel? _response;
  CreateCategoryModel? get response => _response;

  void resetFields() {
    nameController.clear();
    _image = null;
    _queued = false;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final ext = picked.path.split('.').last.toLowerCase();
    if (!(ext == 'png' || ext == 'jpg' || ext == 'jpeg')) {
      _image = null;
      notifyListeners();
      return;
    }

    _image = File(picked.path);
    notifyListeners();
  }

  Future<bool> createCategory(String token) async {
    if (nameController.text.trim().isEmpty || _image == null) return false;

    _loading = true;
    _queued = false;
    notifyListeners();

    // Offline: copy image to permanent storage and queue
    if (!ConnectivityProvider.online) {
      try {
        final permanentPath =
            await OfflineQueue.copyFilePermanent(_image!);
        await OfflineQueue.enqueue(
          type: 'add_category',
          data: {
            'name': nameController.text.trim(),
            'imagePath': permanentPath,
          },
        );
        _queued = true;
      } catch (_) {
        _queued = false;
      }
      _loading = false;
      notifyListeners();
      return _queued;
    }

    try {
      _response = await repository.createCategory(
        name: nameController.text.trim(),
        image: _image,
        token: token,
      );
    } catch (_) {
      _response = null;
    }

    _loading = false;
    notifyListeners();
    return _response?.category != null;
  }

  /// Called on reconnect — submits queued categories.
  Future<void> processOfflineQueue() async {
    final items = await OfflineQueue.getAll();
    final catItems =
        items.where((e) => e['type'] == 'add_category').toList();
    if (catItems.isEmpty) return;

    for (final item in catItems) {
      try {
        final data = item['data'] as Map<String, dynamic>;
        final imageFile = File(data['imagePath'] as String);
        if (!await imageFile.exists()) {
          await OfflineQueue.remove(item['id'] as String);
          continue;
        }
        final result = await repository.createCategory(
          name: data['name'] as String,
          image: imageFile,
          token: '',
        );
        if (result.category != null) {
          await OfflineQueue.remove(item['id'] as String);
          try {
            await imageFile.delete();
          } catch (_) {}
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
