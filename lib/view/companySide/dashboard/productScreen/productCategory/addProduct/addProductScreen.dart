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
import 'package:new_brand/viewModel/providers/productProvider/AnalyzeProductProvider.dart';
import 'package:new_brand/viewModel/providers/productProvider/addProduct_provider.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';
import 'package:new_brand/widgets/customValidation.dart';
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
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _quantityController =
      TextEditingController(); // ✅
  final ValueNotifier<String> selectedStockNotifier = ValueNotifier("In Stock");
  final List<String> stockOptions = const ["In Stock", "Out of Stock"];
  final ValueNotifier<List<File>> selectedImagesNotifier = ValueNotifier([]);
  final ValueNotifier<List<String>> selectedSizesNotifier = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> selectedColorsNotifier =
      ValueNotifier([]);

  // ✅ Analyze image call
  Future<void> _analyzeImage(BuildContext context, File image) async {
    final token = await LocalStorage.getToken();
    final analyzeProvider = Provider.of<AnalyzeProductProvider>(
      context,
      listen: false,
    );

    // ✅ Placeholder dikhao
    _nameController.text = "Analyzing...";
    _descriptionController.text = "Please wait...";

    analyzeProvider.analyzeImage(
      token: token ?? '',
      image: image,
      onSuccess: (name, description) {
        _nameController.text = name;
        _descriptionController.text = description;
      },
      onError: (error) {
        _nameController.text = "";
        _descriptionController.text = "";
        AppToast.show("Could not analyze image");
      },
    );
  }

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
    final token = await LocalStorage.getToken();
    final provider = Provider.of<AddProductProvider>(context, listen: false);

    // ✅ Validation
    if (selectedImagesNotifier.value.isEmpty ||
        _nameController.text.isEmpty ||
        _nameController.text == "Analyzing..." ||
        _beforePriceController.text.isEmpty ||
        _afterPriceController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _quantityController.text.isEmpty) {
      AppToast.show("Please fill all required fields");
      return;
    }

    final weight = int.tryParse(_weightController.text.trim());
    if (weight == null || weight <= 0) {
      AppToast.show("Please enter valid weight in grams");
      return;
    }

    final quantity = int.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity < 0) {
      AppToast.show("Please enter valid quantity");
      return;
    }

    final original = List<File>.from(selectedImagesNotifier.value);
    final validImages = original.where((f) => f.existsSync()).toList();

    if (validImages.isEmpty) {
      AppToast.show("Selected images not found. Please re-select images.");
      return;
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
      quantity: quantity, // ✅
      weightInGrams: weight,
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
    return Scaffold(
      backgroundColor: AppColor.appimagecolor,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 20.h, left: 24.w, right: 24.w),
        child: Consumer<AddProductProvider>(
          builder: (context, provider, _) {
            return CustomButton(
              text: provider.isLoading ? "Adding..." : "Add Product",
              onTap: provider.isLoading ? null : () => _saveProduct(context),
            );
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
                        // ✅ UploadImages with onImageSelected callback
                        UploadImages(
                          selectedImages: selectedImagesNotifier,
                          onImageSelected: (File firstImage) {
                            _analyzeImage(context, firstImage);
                          },
                        ),
                        SizedBox(height: 30.h),

                        // ✅ Analyzing loader dikhao
                        Consumer<AnalyzeProductProvider>(
                          builder: (context, analyzeProvider, _) {
                            if (!analyzeProvider.isAnalyzing) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 16.w,
                                    height: 16.h,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    "AI analyzing image...",
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        CustomTextField(
                          controller: _nameController,
                          hintText: "Enter product name",
                          headerText: 'Product Name',
                          validator: Validators.required,
                        ),
                        SizedBox(height: 20.h),

                        CustomTextField(
                          controller: _descriptionController,
                          hintText: "Enter product description",
                          headerText: 'Description',
                          validator: Validators.required,
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
                        CustomTextField(
                          controller: _weightController,
                          hintText: "Enter weight in grams (e.g. 500)",
                          headerText: 'Weight (grams) *',
                          keyboardType: TextInputType.number,
                        ),

                        SizedBox(height: 20.h),

                        // ✅ Quantity field (stock dropdown hatao, ye lagao)
                        CustomTextField(
                          controller: _quantityController,
                          hintText: "Enter available quantity (e.g. 50)",
                          headerText: 'Quantity *',
                          keyboardType: TextInputType.number,
                        ),

                        SizedBox(height: 20.h),
                        SizeSelect(selectedSizes: selectedSizesNotifier),
                        SizedBox(height: 20.h),

                        ColorSelect(colorNotifier: selectedColorsNotifier),
                        SizedBox(height: 20.h),

                        // Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Text("Stock"),
                        //     SizedBox(height: 8.h),
                        //     ValueListenableBuilder<String>(
                        //       valueListenable: selectedStockNotifier,
                        //       builder: (context, value, _) {
                        //         return DropdownButtonFormField<String>(
                        //           value: value,
                        //           items: stockOptions
                        //               .map(
                        //                 (s) => DropdownMenuItem<String>(
                        //                   value: s,
                        //                   child: Text(s),
                        //                 ),
                        //               )
                        //               .toList(),
                        //           onChanged: (v) {
                        //             if (v == null) return;
                        //             selectedStockNotifier.value = v;
                        //           },
                        //           decoration: const InputDecoration(
                        //             hintText: "Select stock status",
                        //           ),
                        //         );
                        //       },
                        //     ),
                        //   ],
                        // ),
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
