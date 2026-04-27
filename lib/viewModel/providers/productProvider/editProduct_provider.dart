import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProductNotifier extends ChangeNotifier {
  final String oldName;
  final String oldPrice;
  final String oldDescription;
  final String oldColor;
  final String oldSize;
  final int oldQuantity;     // ✅ oldStock ki jagah
  final int oldWeight;       // ✅ new
  final List<String> oldImages;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(); // ✅
  final TextEditingController weightController = TextEditingController();   // ✅

  final List<String> existingImages = [];
  final List<String> deletedExistingImages = [];
  final List<File> newImages = [];

  EditProductNotifier({
    required this.oldName,
    required this.oldPrice,
    required this.oldDescription,
    required this.oldColor,
    required this.oldSize,
    required this.oldQuantity,  // ✅
    required this.oldWeight,    // ✅
    required this.oldImages,
  }) {
    nameController.text = oldName;
    priceController.text = oldPrice;
    descriptionController.text = oldDescription;
    colorController.text = oldColor;
    sizeController.text = oldSize;
    quantityController.text = oldQuantity.toString(); // ✅
    weightController.text = oldWeight.toString();     // ✅

    existingImages.addAll(oldImages);

    // track changes
    nameController.addListener(_onAnyChange);
    priceController.addListener(_onAnyChange);
    descriptionController.addListener(_onAnyChange);
    colorController.addListener(_onAnyChange);
    sizeController.addListener(_onAnyChange);
    quantityController.addListener(_onAnyChange); // ✅
    weightController.addListener(_onAnyChange);   // ✅
  }

  void _onAnyChange() => notifyListeners();

  bool get canAddMore => (existingImages.length + newImages.length) < 5;

  // ✅ isValid - stock check hata, quantity/weight check add
  bool get isValid {
    final n = nameController.text.trim();
    final p = priceController.text.trim();
    final d = descriptionController.text.trim();
    final q = quantityController.text.trim(); // ✅
    final w = weightController.text.trim();   // ✅

    if (n.isEmpty || p.isEmpty || d.isEmpty || q.isEmpty || w.isEmpty) {
      return false;
    }

    if (int.tryParse(p) == null) return false;
    if (int.tryParse(q) == null || int.parse(q) < 0) return false; // ✅
    if (int.tryParse(w) == null || int.parse(w) <= 0) return false; // ✅

    final bool hadColor =
        oldColor.trim().isNotEmpty && oldColor.trim().toLowerCase() != "n/a";
    final bool hadSize =
        oldSize.trim().isNotEmpty && oldSize.trim().toLowerCase() != "n/a";

    if (hadColor && colorController.text.trim().isEmpty) return false;
    if (hadSize && sizeController.text.trim().isEmpty) return false;

    if (existingImages.isEmpty && newImages.isEmpty) return false;

    return true;
  }

  // ✅ isChanged - stock check hata, quantity/weight check add
  bool get isChanged {
    final newName = nameController.text.trim();
    final newPrice = priceController.text.trim();
    final newDesc = descriptionController.text.trim();
    final newColor = colorController.text.trim();
    final newSize = sizeController.text.trim();
    final newQty = int.tryParse(quantityController.text.trim()); // ✅
    final newWgt = int.tryParse(weightController.text.trim());   // ✅

    final bool imagesChanged =
        deletedExistingImages.isNotEmpty || newImages.isNotEmpty;

    if (newName != oldName.trim()) return true;
    if (newPrice != oldPrice.trim()) return true;
    if (newDesc != oldDescription.trim()) return true;

    final bool hadColor =
        oldColor.trim().isNotEmpty && oldColor.trim().toLowerCase() != "n/a";
    final bool hadSize =
        oldSize.trim().isNotEmpty && oldSize.trim().toLowerCase() != "n/a";

    if (hadColor && newColor != oldColor.trim()) return true;
    if (hadSize && newSize != oldSize.trim()) return true;

    if (newQty != null && newQty != oldQuantity) return true; // ✅
    if (newWgt != null && newWgt != oldWeight) return true;   // ✅

    if (imagesChanged) return true;

    return false;
  }

  void removeExisting(int index) {
    if (index < 0 || index >= existingImages.length) return;
    final img = existingImages.removeAt(index);
    deletedExistingImages.add(img);
    notifyListeners();
  }

  void removeNew(int index) {
    if (index < 0 || index >= newImages.length) return;
    newImages.removeAt(index);
    notifyListeners();
  }

  Future<void> pickImages() async {
    if (!canAddMore) return;

    final picker = ImagePicker();
    final remaining = 5 - (existingImages.length + newImages.length);
    final picked = await picker.pickMultiImage();
    if (picked.isEmpty) return;

    for (final x in picked.take(remaining)) {
      newImages.add(File(x.path));
    }
    notifyListeners();
  }

  Future<void> removeMissingFiles() async {
    newImages.removeWhere((f) => !f.existsSync());
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    colorController.dispose();
    sizeController.dispose();
    quantityController.dispose(); // ✅
    weightController.dispose();   // ✅
    super.dispose();
  }
}