import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
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
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  List<File> selectedImages = [];
  List<String> availableSizes = ["Small", "Medium", "Large", "XL", "XXL"];

  final ValueNotifier<List<String>> selectedSizes = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> selectedColorItems =
      ValueNotifier([]); // { name: "red", color: Colors.red OR null }

  // Convert text to Flutter color (returns null if not found)
  Color? _getColorFromName(String name) {
    final colorName = name.toLowerCase().trim();
    switch (colorName) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'brown':
        return Colors.brown;
      default:
        return null;
    }
  }

  // Pick multiple images
  Future<void> _pickImages() async {
    if (selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only upload up to 5 images")),
      );
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      final newImages = picked.map((x) => File(x.path)).toList();
      selectedImages.addAll(newImages.take(5 - selectedImages.length));
      setState(() {});
    }
  }

  void _removeImage(int index) {
    selectedImages.removeAt(index);
    setState(() {});
  }

  // Add colors (or color names) from user input
  void _addColorsFromText(String text) {
    final colorNames = text.split(RegExp(r'[ ,]+')).where((e) => e.isNotEmpty);
    final newEntries = <Map<String, dynamic>>[];

    for (final name in colorNames) {
      final color = _getColorFromName(name);
      final alreadyExists = selectedColorItems.value.any(
        (item) => item["name"].toLowerCase() == name.toLowerCase(),
      );
      if (!alreadyExists) {
        newEntries.add({"name": name, "color": color});
      }
    }

    if (newEntries.isNotEmpty) {
      selectedColorItems.value = [...selectedColorItems.value, ...newEntries];
      _colorController.clear();
    }
  }

  void _saveProduct() {
    if (selectedImages.isEmpty ||
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
                          // Multi Image Picker
                          GestureDetector(
                            onTap: _pickImages,
                            child: CustomAppContainer(
                              height: 140.h,
                              width: double.infinity,

                              child: selectedImages.isEmpty
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo,
                                          color: Colors.white,
                                          size: 40.sp,
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          "Upload Product Images",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ],
                                    )
                                  : SizedBox(
                                      height: 140.h,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: selectedImages.length,
                                        separatorBuilder: (_, __) =>
                                            SizedBox(width: 10.w),
                                        itemBuilder: (context, index) {
                                          return Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20.r),
                                                child: Image.file(
                                                  selectedImages[index],
                                                  fit: BoxFit.cover,
                                                  width: 120.w,
                                                  height: 140.h,
                                                ),
                                              ),
                                              Positioned(
                                                top: 6,
                                                right: 6,
                                                child: GestureDetector(
                                                  onTap: () =>
                                                      _removeImage(index),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withOpacity(0.5),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                            ),
                          ),
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

                          // Size Selector
                          CustomAppContainer(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.w),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Size (Premium)',
                                  style: TextStyle(
                                    color: AppColor.textPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                ValueListenableBuilder<List<String>>(
                                  valueListenable: selectedSizes,
                                  builder: (context, sizes, _) {
                                    return Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: availableSizes.map((size) {
                                        final isSelected = sizes.contains(size);
                                        return FilterChip(
                                          label: Text(size),
                                          selected: isSelected,

                                          selectedColor: AppColor.primaryColor,
                                          checkmarkColor: Colors.white,
                                          onSelected: (value) {
                                            final updated = List<String>.from(
                                              sizes,
                                            );
                                            value
                                                ? updated.add(size)
                                                : updated.remove(size);
                                            selectedSizes.value = updated;
                                          },
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // Color input and display
                          // Color input and display
                          CustomAppContainer(
                            padding: EdgeInsets.all(12.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Input row
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        headerText: "Color",
                                        controller: _colorController,
                                        hintText: 'Type color & tap icon →',
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    GestureDetector(
                                      onTap: () => _addColorsFromText(
                                        _colorController.text,
                                      ),
                                      child: Container(
                                        width: 48.w,
                                        height: 48.w,
                                        decoration: BoxDecoration(
                                          color: AppColor.primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.color_lens,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15.h),

                                // Display colors
                                ValueListenableBuilder<
                                  List<Map<String, dynamic>>
                                >(
                                  valueListenable: selectedColorItems,
                                  builder: (context, colorItems, _) {
                                    if (colorItems.isEmpty)
                                      return const SizedBox();

                                    return Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: colorItems.map((e) {
                                        final color = e['color'];
                                        final name = e['name'];

                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 4.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                color ?? AppColor.primaryColor,
                                            borderRadius: BorderRadius.circular(
                                              20.r,
                                            ),
                                            border: Border.all(
                                              color: Colors.white,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (color == null)
                                                Text(
                                                  name,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              if (color != null)
                                                Container(
                                                  width: 20.w,
                                                  height: 20.w,
                                                  decoration: BoxDecoration(
                                                    color: color,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                ),
                                              SizedBox(width: 4.w),
                                              GestureDetector(
                                                onTap: () {
                                                  selectedColorItems.value =
                                                      colorItems
                                                          .where(
                                                            (item) => item != e,
                                                          )
                                                          .toList();
                                                },
                                                child: const Icon(
                                                  Icons.close,
                                                  size: 18,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

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
