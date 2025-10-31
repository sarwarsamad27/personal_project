import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/CategoryDetailScreen.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProuctCategoryForm.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';
import 'package:new_brand/widgets/productContainer.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Map<String, dynamic>> categories = [
    {
      "name": "Shoes",
      "image":
          "https://cdn.pixabay.com/photo/2016/10/02/22/17/t-shirt-1710578_1280.jpg",
    },
    {
      "name": "Shirts",
      "image":
          "https://cdn.pixabay.com/photo/2016/10/02/22/17/t-shirt-1710578_1280.jpg",
    },
    {
      "name": "Watches",
      "image":
          "https://cdn.pixabay.com/photo/2016/10/02/22/17/t-shirt-1710578_1280.jpg",
    },
    {
      "name": "Bags",
      "image":
          "https://cdn.pixabay.com/photo/2016/10/02/22/17/t-shirt-1710578_1280.jpg",
    },
  ];

  Future<File?> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) return File(picked.path);
    return null;
  }

  void _deleteCategory(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Category"),
        content: const Text("Are you sure you want to delete this category?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() => categories.removeAt(index));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Category deleted successfully")),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editCategory(int index) {
    final oldName = categories[index]['name'];
    final oldImage = categories[index]['image'];
    final nameController = TextEditingController(text: oldName);
    File? newImageFile;
    bool isChanged = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          backgroundColor: Colors.transparent,
          child: CustomAppContainer(
            color: Colors.white70,
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                void checkChanges() {
                  final nameChanged = nameController.text.trim() != oldName;
                  final imageChanged = newImageFile != null;
                  setModalState(() {
                    isChanged = nameChanged || imageChanged;
                  });
                }

                // 🔹 Listen to name changes live
                nameController.addListener(() {
                  checkChanges();
                });

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Edit Category",
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: AppColor.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // 🔹 Full-width Image picker
                    GestureDetector(
                      onTap: () async {
                        final img = await _pickImage();
                        if (img != null) {
                          newImageFile = img;
                          checkChanges();
                        }
                      },
                      child: Container(
                        height: 150.h,
                        width: 150.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppColor.primaryColor.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: newImageFile != null
                            ? Image.file(
                                newImageFile!,
                                fit: BoxFit.cover, // ✅ fills full container
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Image.network(
                                oldImage,
                                fit: BoxFit.cover, // ✅ fills full container
                                width: double.infinity,
                                height: double.infinity,
                              ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // 🔹 Category name field
                    CustomTextField(
                      controller: nameController,
                      headerText: "Category Name",
                      hintText: "Enter new name",
                      prefixIcon: Icons.edit,
                    ),
                    SizedBox(height: 25.h),

                    // 🔹 Buttons row
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: "Cancel",
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Opacity(
                            opacity: isChanged ? 1.0 : 0.5,
                            child: CustomButton(
                              text: "Update",
                              onTap: () {
                                isChanged
                                    ? () {
                                        setState(() {
                                          categories[index]['name'] =
                                              nameController.text.trim();
                                          if (newImageFile != null) {
                                            categories[index]['image'] =
                                                newImageFile!.path;
                                          }
                                        });
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Category updated successfully!",
                                            ),
                                          ),
                                        );
                                      }
                                    : null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.08),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.grid, color: Colors.black87, size: 22),
            SizedBox(width: 8.w),
            Text(
              "Product Categories",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),

      // 🔹 Premium Grid Body
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 260.h,
            crossAxisSpacing: 14.w,
            mainAxisSpacing: 14.h,
          ),
          itemBuilder: (context, index) {
            final item = categories[index];
            return Stack(
              children: [
                CategoryTile(
                  name: item["name"]!,
                  image: item["image"]!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoryProductsScreen(),
                      ),
                    );
                  },
                ),

                // 🔹 Edit/Delete floating options
                Positioned(
                  right: 10,
                  top: 10,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => _editCategory(index),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            LucideIcons.edit,
                            color: AppColor.primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      GestureDetector(
                        onTap: () => _deleteCategory(index),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            LucideIcons.trash2,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),

      // 🔹 Floating Add Button
      floatingActionButton: Container(
        height: 70.h,
        width: 70.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              AppColor.primaryColor,
              AppColor.primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withOpacity(0.35),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddCategoryScreen(),
              ),
            );
          },
          child: const Icon(LucideIcons.plus, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
