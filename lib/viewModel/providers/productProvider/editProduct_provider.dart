import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProductNotifier extends ChangeNotifier {
  final String oldName;
  final String oldPrice;
  final String oldDescription;
  final String oldColor;
  final String oldSize;
  final String oldStock;
  final List<String> oldImages;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();

  // ✅ stock controller (dropdown sync)
  final TextEditingController stockController = TextEditingController();

  final List<String> existingImages = [];
  final List<String> deletedExistingImages = [];
  final List<File> newImages = [];

  EditProductNotifier({
    required this.oldName,
    required this.oldPrice,
    required this.oldDescription,
    required this.oldColor,
    required this.oldSize,
    required this.oldStock,
    required this.oldImages,
  }) {
    nameController.text = oldName;
    priceController.text = oldPrice;
    descriptionController.text = oldDescription;
    colorController.text = oldColor;
    sizeController.text = oldSize;

    stockController.text = (oldStock.trim().toLowerCase() == "out of stock")
        ? "Out of Stock"
        : "In Stock";

    existingImages.addAll(oldImages);

    // track changes
    nameController.addListener(_onAnyChange);
    priceController.addListener(_onAnyChange);
    descriptionController.addListener(_onAnyChange);
    colorController.addListener(_onAnyChange);
    sizeController.addListener(_onAnyChange);
    stockController.addListener(_onAnyChange);
  }

  void _onAnyChange() {
    notifyListeners();
  }

  bool get canAddMore => (existingImages.length + newImages.length) < 5;

  // ✅ Stock setter so dropdown change immediately enables Update
  void setStock(String v) {
    stockController.text = v;
    notifyListeners();
  }

  // ✅ Block empty updates for fields that exist
  bool get isValid {
    final n = nameController.text.trim();
    final p = priceController.text.trim();
    final d = descriptionController.text.trim();
    final st = stockController.text.trim();

    if (n.isEmpty || p.isEmpty || d.isEmpty || st.isEmpty) return false;
    if (int.tryParse(p) == null) return false;
    if (st != "In Stock" && st != "Out of Stock") return false;

    final bool hadColor =
        oldColor.trim().isNotEmpty && oldColor.trim().toLowerCase() != "n/a";
    final bool hadSize =
        oldSize.trim().isNotEmpty && oldSize.trim().toLowerCase() != "n/a";

    if (hadColor && colorController.text.trim().isEmpty) return false;
    if (hadSize && sizeController.text.trim().isEmpty) return false;

    // Must have at least 1 image (existing or new)
    if (existingImages.isEmpty && newImages.isEmpty) return false;

    return true;
  }

  // ✅ used by UI to enable/disable Update
  bool get isChanged {
    final newName = nameController.text.trim();
    final newPrice = priceController.text.trim();
    final newDesc = descriptionController.text.trim();
    final newColor = colorController.text.trim();
    final newSize = sizeController.text.trim();
    final newStock = stockController.text.trim();

    final bool imagesChanged =
        deletedExistingImages.isNotEmpty || newImages.isNotEmpty;

    if (newName != oldName.trim()) return true;
    if (newPrice != oldPrice.trim()) return true;
    if (newDesc != oldDescription.trim()) return true;

    // Only consider color/size change if they existed originally
    final bool hadColor =
        oldColor.trim().isNotEmpty && oldColor.trim().toLowerCase() != "n/a";
    final bool hadSize =
        oldSize.trim().isNotEmpty && oldSize.trim().toLowerCase() != "n/a";

    if (hadColor && newColor != oldColor.trim()) return true;
    if (hadSize && newSize != oldSize.trim()) return true;

    if (newStock.toLowerCase() != oldStock.trim().toLowerCase()) return true;

    if (imagesChanged) return true;

    return false;
  }

  // Existing image remove
  void removeExisting(int index) {
    if (index < 0 || index >= existingImages.length) return;
    final img = existingImages.removeAt(index);
    deletedExistingImages.add(img);
    notifyListeners();
  }

  // New image remove
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

    // take only remaining slots
    for (final x in picked.take(remaining)) {
      newImages.add(File(x.path));
    }

    notifyListeners();
  }

  // remove missing cache files (as you were doing)
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
    stockController.dispose();
    super.dispose();
  }
}
