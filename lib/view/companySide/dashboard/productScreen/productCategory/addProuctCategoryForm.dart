import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _saveCategory() {
    if (_nameController.text.isNotEmpty && _selectedImage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Category added successfully!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select image and name")),
      );
    }
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
                  "Add Category",
                  style: TextStyle(
                    fontSize: 28.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 40.h),

                // 🔹 Main Glass Container
                Expanded(
                  child: Center(
                    child: CustomAppContainer(
                      width: double.infinity,
                      padding: EdgeInsets.all(24.w),

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 🔹 Image Picker
                          GestureDetector(
                            onTap: _pickImage,
                            child: CustomAppContainer(
                              height: 140.h,
                              width: 140.w,

                              child: _selectedImage == null
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
                                          "Upload Image",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ],
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(25.r),
                                      child: Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                            ),
                          ),

                          SizedBox(height: 30.h),

                          // 🔹 Category Name Field
                          CustomTextField(
                            controller: _nameController,

                            hintText: "Enter category name",
                            headerText: 'Category Name',
                          ),

                          SizedBox(height: 30.h),

                          CustomButton(
                            text: "Add Category",
                            onTap: () {
                              _saveCategory();
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
