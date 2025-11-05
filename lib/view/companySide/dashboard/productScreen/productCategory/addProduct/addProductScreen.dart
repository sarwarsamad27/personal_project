import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/colorSelect.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/sizeSelect.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/uploadImages.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';

// ignore: must_be_immutable
class AddProductScreen extends StatelessWidget {
  AddProductScreen({super.key});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _beforePriceController = TextEditingController();
  final TextEditingController _afterPriceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  final ValueNotifier<List<File>> selectedImagesNotifier = ValueNotifier([]);

  List<String> availableSizes = ["Small", "Medium", "Large", "XL", "XXL"];

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
            "After Discount Price must be less than Before Discount Price",
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

  void _saveProduct(BuildContext context) {
    if (selectedImagesNotifier.value.isEmpty ||
        _nameController.text.isEmpty ||
        _beforePriceController.text.isEmpty ||
        _afterPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Product added successfully!")),
    );
    Navigator.pop(context);
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
                          UploadImages(),
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

                          // Auto Discount %
                          CustomTextField(
                            controller: _discountController,
                            hintText: "Discount %",
                            headerText: 'Discount Percentage',
                            readOnly: true,
                          ),
                          SizedBox(height: 20.h),

                          SizeSelect(),
                          SizedBox(height: 20.h),

                          ColorSelect(),
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
                            onTap: () => _saveProduct(context),
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
