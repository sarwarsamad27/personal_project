import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/models/categoryModel/getCategory_model.dart';
import 'package:new_brand/resources/local_storage.dart';
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
  final TextEditingController _stockController = TextEditingController();

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "After discount price must be less than before discount price",
          ),
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    provider.addProduct(
      token: token,
      categoryId: category.sId!,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      images: selectedImagesNotifier.value,
      beforePrice: int.tryParse(_beforePriceController.text),
      afterPrice: int.tryParse(_afterPriceController.text),
      size: selectedSizesNotifier.value,
      color: selectedColorsNotifier.value
          .map((e) => e["name"].toString())
          .toList(),
      stock: int.tryParse(_stockController.text),
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product added successfully!")),
        );
        Navigator.pop(context);
      },
      onError: (msg) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBgContainer(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
            child: Column(
              children: [
                Text(
                  "Add Product",
                  style: TextStyle(
                    fontSize: 28.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40.h),
                Expanded(
                  child: SingleChildScrollView(
                    child: CustomAppContainer(
                      width: double.infinity,
                      padding: EdgeInsets.all(24.w),
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

                          CustomTextField(
                            controller: _stockController,
                            hintText: "Enter available stock",
                            headerText: 'Stock Quantity',
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 35.h),

                          CustomButton(
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
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
