import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_brand/models/categoryModel/createCategory_model.dart';
import 'package:new_brand/viewModel/repository/categoryRepository/createCategory_repository.dart';

class CreateCategoryProvider with ChangeNotifier {
  final CreateCategoryRepository repository = CreateCategoryRepository();
  final TextEditingController nameController = TextEditingController();

  bool _loading = false;
  bool get loading => _loading;

  File? _image;
  File? get image => _image;

  CreateCategoryModel? _response;
  CreateCategoryModel? get response => _response;

  void resetFields() {
    nameController.clear();
    _image = null;
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
    if (nameController.text.trim().isEmpty || _image == null) {
      return false;
    }

    _loading = true;
    notifyListeners();

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

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
