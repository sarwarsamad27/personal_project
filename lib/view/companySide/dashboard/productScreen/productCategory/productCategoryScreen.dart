import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/models/categoryModel/getCategory_model.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/CategoryDetailScreen.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProuctCategoryForm.dart';
import 'package:new_brand/viewModel/providers/categoryProvider/getcategory_provider.dart';
import 'package:new_brand/viewModel/providers/categoryProvider/updateAndDeleteCategory_provider.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';
import 'package:new_brand/widgets/productContainer.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider = Provider.of<GetCategoryProvider>(context, listen: false);
      await provider.getCategories();
    });
  }

  Future<File?> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) return File(picked.path);
    return null;
  }

  void _deleteCategory(BuildContext context, String id) async {
    final provider = Provider.of<UpdateDeleteCategoryProvider>(
      context,
      listen: false,
    );

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
            onPressed: () async {
              Navigator.pop(context); // close dialog first

              final success = await provider.deleteCategory(categoryId: id);
              if (!mounted) return;

              if (success) {
                AppToast.success("Category deleted successfully!");
                Provider.of<GetCategoryProvider>(
                  context,
                  listen: false,
                ).getCategories(forceRefresh: true);
              } else {
                AppToast.error("Failed to delete category");
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editCategory(BuildContext context, Categories cat) {
    final provider = Provider.of<UpdateDeleteCategoryProvider>(
      context,
      listen: false,
    );

    final oldName = (cat.name ?? "").trim();
    final oldImage = (cat.image ?? "");
    final oldImageUrl = oldImage.startsWith("http")
        ? oldImage
        : Global.imageUrl + oldImage;

    final nameController = TextEditingController(text: oldName);
    File? newImageFile;

    bool isChanged = false;
    bool listenerAdded = false;

    void checkChanges(void Function(void Function()) setModalState) {
      final nameChanged = nameController.text.trim() != oldName;
      final imageChanged = newImageFile != null;
      setModalState(() {
        isChanged = nameChanged || imageChanged;
      });
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          backgroundColor: Colors.transparent,
          child: CustomAppContainer(
            color: Colors.white70,
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            child: StatefulBuilder(
              builder: (BuildContext ctx, setModalState) {
                // ✅ add listener only once
                if (!listenerAdded) {
                  listenerAdded = true;
                  nameController.addListener(() => checkChanges(setModalState));
                }

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

                    GestureDetector(
                      onTap: () async {
                        final img = await _pickImage();
                        if (img != null) {
                          newImageFile = img;
                          checkChanges(setModalState);
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
                            ? Image.file(newImageFile!, fit: BoxFit.cover)
                            : Image.network(
                                oldImageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(Icons.broken_image),
                                  );
                                },
                              ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    CustomTextField(
                      controller: nameController,
                      headerText: "Category Name",
                      hintText: "Enter new name",
                      prefixIcon: Icons.edit,
                    ),

                    SizedBox(height: 25.h),

                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: "Cancel",
                            onTap: () {
                              Navigator.pop(dialogCtx); // ✅ only close dialog
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Opacity(
                            opacity: isChanged ? 1 : 0.5,
                            child: CustomButton(
                              text: provider.isLoading
                                  ? "Please wait..."
                                  : "Update",
                              onTap: isChanged
                                  ? () async {
                                      final success = await provider
                                          .updateCategory(
                                            categoryId: cat.sId ?? "",
                                            name: nameController.text.trim(),
                                            image: newImageFile,
                                          );

                                      // if (!mounted) return;

                                      // ✅ close dialog first
                                      Navigator.pop(dialogCtx);

                                      // ✅ toast + refresh after dialog closes
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            if (!mounted) return;

                                            if (success) {
                                              AppToast.show(
                                                "Category updated!",
                                              );
                                              Provider.of<GetCategoryProvider>(
                                                context,
                                                listen: false,
                                              ).getCategories(
                                                forceRefresh: true,
                                              );
                                            } else {
                                              AppToast.show(
                                                "Failed to update category",
                                              );
                                            }
                                          });
                                    }
                                  : null,
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
    final provider = Provider.of<GetCategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.appimagecolor,
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
      body: provider.isLoading
          ? const Center(
              child: SpinKitThreeBounce(
                color: AppColor.primaryColor,
                size: 30.0,
              ),
            )
          : provider.categoryData == null ||
                provider.categoryData!.categories == null
          ? const Center(child: Text("No categories found"))
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: GridView.builder(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                itemCount: provider.categoryData!.categories!.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 240.h,
                  crossAxisSpacing: 14.w,
                  mainAxisSpacing: 0.h,
                ),
                itemBuilder: (context, index) {
                  final item = provider.categoryData!.categories![index];
                  log(item.image.toString());

                  return Stack(
                    children: [
                      CategoryTile(
                        name: item.name ?? "",
                        image: Global.imageUrl + (item.image ?? ""),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CategoryProductsScreen(category: item),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => _editCategory(context, item),
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
                              onTap: () =>
                                  _deleteCategory(context, item.sId ?? ""),
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
      floatingActionButton: Container(
        height: 70.h,
        width: 70.h,
        margin: EdgeInsets.only(bottom: 70.h),
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
          onPressed: () async {
            final added = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
            );

            if (!mounted) return;

            if (added == true) {
              // ✅ toast yahan show karo (safe, no navigator lock)
              AppToast.success("Category added successfully!");
              Provider.of<GetCategoryProvider>(
                context,
                listen: false,
              ).getCategories(forceRefresh: true);
            }
          },
          child: const Icon(LucideIcons.plus, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
