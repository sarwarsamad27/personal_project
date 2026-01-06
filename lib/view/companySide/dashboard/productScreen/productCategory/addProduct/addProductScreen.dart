import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/models/categoryModel/getCategory_model.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/colorSelect.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/sizeSelect.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/uploadImages.dart';
import 'package:new_brand/viewModel/providers/productProvider/addProduct_provider.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AddProductScreen extends StatelessWidget {
  final Categories category;
  AddProductScreen({super.key, required this.category});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _beforePriceController = TextEditingController();
  final TextEditingController _afterPriceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
final ValueNotifier<String> selectedStockNotifier = ValueNotifier("In Stock");

final List<String> stockOptions = const ["In Stock", "Out of Stock"];
  final ValueNotifier<List<File>> selectedImagesNotifier = ValueNotifier([]);
  final ValueNotifier<List<String>> selectedSizesNotifier = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> selectedColorsNotifier =
      ValueNotifier([]);

  void _calculateDiscount(BuildContext context) {
    final beforeText = _beforePriceController.text.trim();
    final afterText = _afterPriceController.text.trim();

    if (beforeText.isEmpty || afterText.isEmpty) {
      _discountController.text = "";
      return;
    }

    final before = double.tryParse(beforeText);
    final after = double.tryParse(afterText);

    if (before == null || after == null) return;

    if (after > before) {
      AppToast.show(
        "After discount price must be less than before discount price",
      );
      _afterPriceController.clear();
      _discountController.text = "";
      return;
    }

    final discount = ((before - after) / before) * 100;
    _discountController.text = "${discount.toStringAsFixed(1)}%";
  }

  void _saveProduct(BuildContext context) async {
    final token = await LocalStorage.getToken(); // FIXED 💯
    final provider = Provider.of<AddProductProvider>(context, listen: false);

    if (selectedImagesNotifier.value.isEmpty ||
        _nameController.text.isEmpty ||
        _beforePriceController.text.isEmpty ||
        _afterPriceController.text.isEmpty) {
      AppToast.show("Please fill all required fields");
      return;
    }

    // ✅ FIX: remove missing cache files
    final original = List<File>.from(selectedImagesNotifier.value);
    final validImages = original.where((f) => f.existsSync()).toList();

    if (validImages.isEmpty) {
      AppToast.show("Selected images not found. Please re-select images.");
      return;
    }

    if (validImages.length != original.length) {
      selectedImagesNotifier.value = validImages;
      AppToast.show(
        "Some images were removed (file not found). Please re-select if needed.",
      );
    }

    provider.addProduct(
      token: token,
      categoryId: category.sId!,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      images: validImages,
      beforePrice: int.tryParse(_beforePriceController.text),
      afterPrice: int.tryParse(_afterPriceController.text),
      size: selectedSizesNotifier.value,
      color: selectedColorsNotifier.value
          .map((e) => e["name"].toString())
          .toList(),
      stock: selectedStockNotifier.value,

      onSuccess: () {
        AppToast.show("Product added successfully!");
        Navigator.pop(context);
      },
      onError: (msg) {
        AppToast.show(msg);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Bottom bar height estimate so container never hides under it

    return Scaffold(
      backgroundColor: AppColor.appimagecolor,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 20.h, left: 24.w, right: 24.w),
        child: CustomButton(
          text: "Add Product",
          onTap: () {
            _saveProduct(context);

            print("NAME: ${_nameController.text}");
            print("DESC: ${_descriptionController.text}");
            print("Before: ${_beforePriceController.text}");
            print("After: ${_afterPriceController.text}");
            print("Sizes: ${selectedSizesNotifier.value}");
            print("Colors: ${selectedColorsNotifier.value}");
            print("Images: ${selectedImagesNotifier.value}");
          },
        ),
      ),
      body: CustomBgContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
          child: Column(
            children: [
              Expanded(
                child: CustomAppContainer(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        UploadImages(selectedImages: selectedImagesNotifier),
                        SizedBox(height: 30.h),

                        CustomTextField(
                          controller: _nameController,
                          hintText: "Enter product name",
                          headerText: 'Product Name',
                        ),
                        SizedBox(height: 20.h),

                        CustomTextField(
                          controller: _descriptionController,
                          hintText: "Enter product description",
                          headerText: 'Description',
                        ),
                        SizedBox(height: 20.h),

                        CustomTextField(
                          controller: _beforePriceController,
                          hintText: "Enter before discount price (e.g. 4999)",
                          headerText: 'Before Discount Price',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _calculateDiscount(context),
                        ),
                        SizedBox(height: 20.h),

                        CustomTextField(
                          controller: _afterPriceController,
                          hintText: "Enter after discount price (e.g. 3999)",
                          headerText: 'After Discount Price',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _calculateDiscount(context),
                        ),
                        SizedBox(height: 20.h),

                        CustomTextField(
                          controller: _discountController,
                          hintText: "Discount %",
                          headerText: 'Discount Percentage',
                          readOnly: true,
                        ),
                        SizedBox(height: 20.h),

                        SizeSelect(selectedSizes: selectedSizesNotifier),
                        SizedBox(height: 20.h),

                        ColorSelect(colorNotifier: selectedColorsNotifier),
                        SizedBox(height: 20.h),

                       Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      "Stock",
      // agar aapka CustomTextField header style use hota hai to yahan same style apply kar dein
      // style: ...
    ),
    SizedBox(height: 8.h),
    ValueListenableBuilder<String>(
      valueListenable: selectedStockNotifier,
      builder: (context, value, _) {
        return DropdownButtonFormField<String>(
          value: value,
          items: stockOptions
              .map((s) => DropdownMenuItem<String>(
                    value: s,
                    child: Text(s),
                  ))
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            selectedStockNotifier.value = v;
          },
          decoration: InputDecoration(
            hintText: "Select stock status",
            // agar aapke app me consistent borders/padding chahiye to yahan set kar sakte hain
          ),
        );
      },
    ),
  ],
),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
