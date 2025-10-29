import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customTextFeld.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  String? _selectedCategory;
  final List<String> _categories = ['Shoes', 'Clothing', 'Accessories', 'Other'];

  List<File> _selectedImages = [];

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      setState(() {
        _selectedImages = picked.map((x) => File(x.path)).toList();
      });
    }
  }

  void _saveProduct() {
    if (_selectedImages.isEmpty ||
        _nameController.text.isEmpty ||
        _priceController.text.isEmpty) {
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
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD2A1), Color(0xFFDF762E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
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
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 40.h),

                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // 🔹 Multi Image Picker
                          GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              height: 140.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(25.r),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 2,
                                ),
                              ),
                              child: _selectedImages.isEmpty
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo,
                                            color: Colors.white, size: 40.sp),
                                        SizedBox(height: 8.h),
                                        Text(
                                          "Upload Product Images",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.sp),
                                        ),
                                      ],
                                    )
                                  : SizedBox(
                                      height: 140.h,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _selectedImages.length,
                                        separatorBuilder: (_, __) =>
                                            SizedBox(width: 10.w),
                                        itemBuilder: (context, index) {
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20.r),
                                            child: Image.file(
                                              _selectedImages[index],
                                              fit: BoxFit.cover,
                                              width: 120.w,
                                              height: 140.h,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                            ),
                          ),

                          SizedBox(height: 30.h),

                          // 🔹 Text Fields
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
                            maxLines: 3,
                          ),
                          SizedBox(height: 20.h),

                          CustomTextField(
                            controller: _priceController,
                            hintText: "Enter price (e.g. 4999)",
                            headerText: 'Price',
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 20.h),

                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _sizeController,
                                  hintText: "M, L, XL",
                                  headerText: 'Size',
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: CustomTextField(
                                  controller: _colorController,
                                  hintText: "Enter color",
                                  headerText: 'Color',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),

                          CustomTextField(
                            controller: _stockController,
                            hintText: "Enter available stock",
                            headerText: 'Stock Quantity',
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 20.h),

                          // 🔹 Category Dropdown
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15.r),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.4)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                dropdownColor: Colors.orange.shade100,
                                value: _selectedCategory,
                                hint: Text(
                                  "Select Category",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14.sp),
                                ),
                                items: _categories
                                    .map((cat) => DropdownMenuItem(
                                          value: cat,
                                          child: Text(cat),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                },
                              ),
                            ),
                          ),

                          SizedBox(height: 35.h),

                          CustomButton(
                            text: "Add Product",
                            onTap: _saveProduct,
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
