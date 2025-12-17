import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/viewModel/providers/productProvider/deleteProduct_provider.dart';
import 'package:new_brand/viewModel/providers/productProvider/getSingleProduct_provider.dart';
import 'package:new_brand/viewModel/providers/productProvider/updateProduct_provider.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProductImage extends StatelessWidget {
  final List<String> imageUrls;
  final String name;
  final String description;
  final String color;
  final String size;
  final String price;
  final String categoryId;
  final String productId;

  ProductImage({
    super.key,
    required this.imageUrls,
    required this.name,
    required this.productId,
    required this.description,
    required this.color,
    required this.size,
    required this.price,
    required this.categoryId,
  });

  final PageController _pageController = PageController();

  void _deleteProduct(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Product"),
        content: const Text(
          "Are you sure you want to delete this product permanently?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              final token = await LocalStorage.getToken() ?? "";

              final provider = Provider.of<DeleteProductProvider>(
                context,
                listen: false,
              );

              await provider.deleteProduct(productId: productId, token: token);

              if (provider.deleteProductModel?.message != null) {
                 AppToast.show(provider.deleteProductModel!.message!);
                Navigator.pop(context); // Close product detail screen
              } else {
                AppToast.show("Failed to delete product");
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editProduct(BuildContext context) {
    String oldName = name;
    String oldPrice = price.replaceAll("PKR ", "");
    String oldDescription = description;
    String oldColor = color;
    String oldSize = size;
    List<String> oldImages = List<String>.from(imageUrls);

    final nameController = TextEditingController(text: oldName);
    final priceController = TextEditingController(text: oldPrice);
    final descriptionController = TextEditingController(text: oldDescription);
    final colorController = TextEditingController(text: oldColor);
    final sizeController = TextEditingController(text: oldSize);

    List<File> newImages = [];
    List<String> existingImages = List<String>.from(oldImages);

    bool isChanged = false;

    Future<void> _pickImages(StateSetter setModalState) async {
      if (existingImages.length + newImages.length >= 5) {
         AppToast.show("You can only upload up to 5 images");
        return;
      }

      final picked = await ImagePicker().pickMultiImage();
      if (picked.isNotEmpty) {
        final selected = picked.map((x) => File(x.path)).toList();
        setModalState(() {
          newImages.addAll(
            selected.take(5 - (existingImages.length + newImages.length)),
          );
          isChanged = true;
        });
      }
    }

    void _removeExistingImage(int index, StateSetter setModalState) {
      setModalState(() {
        existingImages.removeAt(index);
        isChanged = true;
      });
    }

    void _removeNewImage(int index, StateSetter setModalState) {
      setModalState(() {
        newImages.removeAt(index);
        isChanged = true;
      });
    }

    void _checkChanges(StateSetter setModalState) {
      final nameChanged = nameController.text.trim() != oldName;
      final priceChanged = priceController.text.trim() != oldPrice;
      final descChanged = descriptionController.text.trim() != oldDescription;
      final colorChanged = colorController.text.trim() != oldColor;
      final sizeChanged = sizeController.text.trim() != oldSize;
      setModalState(() {
        isChanged =
            nameChanged ||
            priceChanged ||
            descChanged ||
            colorChanged ||
            sizeChanged ||
            newImages.isNotEmpty ||
            existingImages.length != oldImages.length;
      });
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
          backgroundColor: Colors.transparent,
          child: CustomAppContainer(
            color: Colors.white70,
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                nameController.addListener(() => _checkChanges(setModalState));
                priceController.addListener(() => _checkChanges(setModalState));
                descriptionController.addListener(
                  () => _checkChanges(setModalState),
                );
                colorController.addListener(() => _checkChanges(setModalState));
                sizeController.addListener(() => _checkChanges(setModalState));

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Edit Product",
                        style: TextStyle(
                          fontSize: 20.sp,
                          color: AppColor.textPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Product Images (Max 5)",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColor.textPrimaryColor,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      SizedBox(
                        height: 110.h,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            ...List.generate(existingImages.length, (i) {
                              return Stack(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 10.w),
                                    width: 110.w,
                                    height: 110.h,
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                    child: Image.network(
                                      Global.imageUrl + existingImages[i],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeExistingImage(
                                        i,
                                        setModalState,
                                      ),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                            ...List.generate(newImages.length, (i) {
                              return Stack(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 10.w),
                                    width: 110.w,
                                    height: 110.h,
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                    child: Image.file(
                                      newImages[i],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () =>
                                          _removeNewImage(i, setModalState),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                            if (existingImages.length + newImages.length < 5)
                              GestureDetector(
                                onTap: () => _pickImages(setModalState),
                                child: Container(
                                  width: 110.w,
                                  height: 110.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14.r),
                                    border: Border.all(
                                      color: AppColor.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add_a_photo_outlined,
                                    color: AppColor.primaryColor,
                                    size: 30.sp,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      CustomTextField(
                        controller: nameController,
                        headerText: "Product Name",
                        hintText: "Enter product name",
                        prefixIcon: Icons.edit,
                      ),
                      SizedBox(height: 15.h),
                      CustomTextField(
                        controller: priceController,
                        headerText: "Price",
                        hintText: "Enter price (PKR)",
                        prefixIcon: Icons.currency_rupee,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 15.h),
                      CustomTextField(
                        controller: descriptionController,
                        headerText: "Description",
                        hintText: "Write description",
                        height: 100.h,
                      ),
                      SizedBox(height: 15.h),
                      CustomTextField(
                        controller: colorController,
                        headerText: "Color",
                        hintText: "Enter product color",
                        prefixIcon: Icons.palette_outlined,
                      ),
                      SizedBox(height: 15.h),
                      CustomTextField(
                        controller: sizeController,
                        headerText: "Size",
                        hintText: "Enter available size",
                        prefixIcon: Icons.straighten,
                      ),
                      SizedBox(height: 25.h),
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
                                onTap: () async {
                                  if (!isChanged) return;

                                  final token =
                                      await LocalStorage.getToken() ?? "";

                                  final provider =
                                      Provider.of<UpdateProductProvider>(
                                        context,
                                        listen: false,
                                      );

                                  await provider.updateProduct(
                                    productId: productId,
                                    token: token,
                                    name: nameController.text.trim(),
                                    description: descriptionController.text
                                        .trim(),
                                    afterDiscountPrice:
                                        int.tryParse(
                                          priceController.text.trim(),
                                        ) ??
                                        0,
                                    beforeDiscountPrice:
                                        int.tryParse(
                                          priceController.text.trim(),
                                        ) ??
                                        0,
                                    size: sizeController.text.trim().split(','),
                                    color: colorController.text.trim().split(
                                      ',',
                                    ),
                                    stock: 10, 
                                    images: newImages,
                                  );

                                  if (provider.updateProductModel?.product !=
                                      null) {
                                    Navigator.pop(context); // Close dialog

                                    // Show success message
                                    AppToast.show("Product updated successfully");

                                    // ------------------- RE-FETCH PRODUCT -------------------
                                    final getProvider =
                                        Provider.of<GetSingleProductProvider>(
                                          context,
                                          listen: false,
                                        );
                                    final token =
                                        await LocalStorage.getToken() ?? "";
                                    await getProvider.fetchSingleProducts(
                                      token: token,
                                      categoryId: categoryId,
                                      productId: productId,
                                    );
                                    // ---------------------------------------------------------
                                  } else {
                                   AppToast.error("Update failed");
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
    return SizedBox(
      height: 0.45.sh,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24.r),
                  bottomRight: Radius.circular(24.r),
                ),
                child: Image.network(
                  Global.imageUrl + imageUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              );
            },
          ),
          Positioned(
            bottom: 16.h,
            child: SmoothPageIndicator(
              controller: _pageController,
              count: imageUrls.length,
              effect: ExpandingDotsEffect(
                activeDotColor: Colors.black,
                dotColor: Colors.grey[400]!,
                dotHeight: 8.h,
                dotWidth: 8.w,
                spacing: 6.w,
              ),
            ),
          ),
          Positioned(
            top: 12.h,
            left: 12.w,
            child: CircleAvatar(
              backgroundColor: Colors.white70,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(
            top: 12.h,
            right: 12.w,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _editProduct(context),
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
                      Icons.edit,
                      color: AppColor.primaryColor,
                      size: 22,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                GestureDetector(
                  onTap: () => _deleteProduct(context),
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
                      Icons.delete,
                      color: Colors.redAccent,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
