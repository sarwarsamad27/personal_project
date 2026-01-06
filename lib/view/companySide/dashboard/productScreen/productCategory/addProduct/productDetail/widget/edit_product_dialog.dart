import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/viewModel/providers/productProvider/editProduct_provider.dart';
import 'package:new_brand/viewModel/providers/productProvider/getSingleProduct_provider.dart';
import 'package:new_brand/viewModel/providers/productProvider/updateProduct_provider.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';
import 'package:provider/provider.dart';

class EditProductDialog extends StatelessWidget {
  final String productId;
  final String categoryId;

  final List<String> imageUrls;
  final String name;
  final String description;
  final String color;
  final String size;
  final String price;
  final String stock;

  const EditProductDialog({
    super.key,
    required this.productId,
    required this.categoryId,
    required this.imageUrls,
    required this.name,
    required this.description,
    required this.color,
    required this.size,
    required this.price,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> stockOptions = const ["In Stock", "Out of Stock"];

    final oldPrice = price.replaceAll("PKR", "").replaceAll(":", "").trim();
    final oldStock = stock.trim().isEmpty ? "In Stock" : stock.trim();

    final bool hasColors =
        color.trim().isNotEmpty && color.trim().toLowerCase() != "n/a";
    final bool hasSizes =
        size.trim().isNotEmpty && size.trim().toLowerCase() != "n/a";

    return ChangeNotifierProvider(
      create: (_) => EditProductNotifier(
        oldName: name,
        oldPrice: oldPrice,
        oldDescription: description,
        oldColor: color,
        oldSize: size,
        oldStock: oldStock,
        oldImages: imageUrls,
      ),
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
        backgroundColor: Colors.transparent,
        child: CustomAppContainer(
          color: Colors.white70,
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          child: Consumer<EditProductNotifier>(
            builder: (context, s, _) {
              final bool canUpdate = s.isChanged && s.isValid;

              // current dropdown value from controller (single source)
              final String currentStock = (s.stockController.text.trim().isEmpty)
                  ? "In Stock"
                  : s.stockController.text.trim();

              final String normalizedDropdownValue =
                  (currentStock.toLowerCase() == "out of stock")
                      ? "Out of Stock"
                      : "In Stock";

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
                          ...List.generate(s.existingImages.length, (i) {
                            return _ExistingImageTile(
                              imagePath: s.existingImages[i],
                              onRemove: () => s.removeExisting(i),
                            );
                          }),
                          ...List.generate(s.newImages.length, (i) {
                            return _NewImageTile(
                              file: s.newImages[i],
                              onRemove: () => s.removeNew(i),
                            );
                          }),
                          if (s.canAddMore)
                            GestureDetector(
                              onTap: () => s.pickImages(),
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
                      controller: s.nameController,
                      headerText: "Product Name",
                      hintText: "Enter product name",
                      prefixIcon: Icons.edit,
                    ),
                    SizedBox(height: 15.h),
                    CustomTextField(
                      controller: s.priceController,
                      headerText: "Price",
                      hintText: "Enter price (PKR)",
                      prefixIcon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 15.h),
                    CustomTextField(
                      controller: s.descriptionController,
                      headerText: "Description",
                      hintText: "Write description",
                      height: 100.h,
                    ),
                    SizedBox(height: 15.h),

                    // ✅ show only if product had colors
                    if (hasColors) ...[
                      CustomTextField(
                        controller: s.colorController,
                        headerText: "Color",
                        hintText: "Enter product color",
                        prefixIcon: Icons.palette_outlined,
                      ),
                      SizedBox(height: 15.h),
                    ],

                    // ✅ show only if product had sizes
                    if (hasSizes) ...[
                      CustomTextField(
                        controller: s.sizeController,
                        headerText: "Size",
                        hintText: "Enter available size",
                        prefixIcon: Icons.straighten,
                      ),
                      SizedBox(height: 15.h),
                    ],

                    // ----------- STOCK FIELD (DROPDOWN) -----------
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Stock"),
                        SizedBox(height: 8.h),
                        DropdownButtonFormField<String>(
                          value: normalizedDropdownValue,
                          items: stockOptions
                              .map(
                                (v) => DropdownMenuItem<String>(
                                  value: v,
                                  child: Text(v),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            // ✅ stock change triggers isChanged/isValid re-eval
                            s.setStock(v);
                          },
                          decoration: const InputDecoration(
                            hintText: "Select stock status",
                          ),
                        ),
                      ],
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
                            opacity: canUpdate ? 1.0 : 0.5,
                            child: CustomButton(
                              text: "Update",
                              onTap: canUpdate
                                  ? () async {
                                      await s.removeMissingFiles();

                                      final validNewImages = s.newImages
                                          .where((f) => f.existsSync())
                                          .toList();

                                      if (validNewImages.length !=
                                          s.newImages.length) {
                                        AppToast.show(
                                          "Some selected images were removed (file not found). Please re-select.",
                                        );
                                      }

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
                                        name: s.nameController.text.trim(),
                                        description: s.descriptionController.text
                                            .trim(),
                                        afterDiscountPrice: int.tryParse(
                                              s.priceController.text.trim(),
                                            ) ??
                                            0,
                                        beforeDiscountPrice: int.tryParse(
                                              s.priceController.text.trim(),
                                            ) ??
                                            0,

                                        // ✅ only send if section exists, otherwise send empty list same as earlier logic
                                        size: hasSizes
                                            ? s.sizeController.text
                                                .trim()
                                                .split(',')
                                            : <String>[],
                                        color: hasColors
                                            ? s.colorController.text
                                                .trim()
                                                .split(',')
                                            : <String>[],

                                        // ✅ stock from controller (synced with dropdown)
                                        stock: s.stockController.text.trim(),

                                        images: validNewImages,

                                        keepImages: s.existingImages,
                                        deleteImages: s.deletedExistingImages,
                                      );

                                      if (provider.updateProductModel?.product !=
                                          null) {
                                        Navigator.pop(context);

                                        AppToast.show(
                                          "Product updated successfully",
                                        );

                                        final getProvider =
                                            Provider.of<GetSingleProductProvider>(
                                          context,
                                          listen: false,
                                        );

                                        final token2 =
                                            await LocalStorage.getToken() ?? "";
                                        await getProvider.fetchSingleProducts(
                                          token: token2,
                                          categoryId: categoryId,
                                          productId: productId,
                                        );
                                      } else {
                                        AppToast.error("Update failed");
                                      }
                                    }
                                  : null,
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
      ),
    );
  }
}

// Tiles same as your existing code
class _ExistingImageTile extends StatelessWidget {
  final String imagePath;
  final VoidCallback onRemove;

  const _ExistingImageTile({required this.imagePath, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(right: 10.w),
          width: 110.w,
          height: 110.h,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.r)),
          child: Image.network(Global.imageUrl + imagePath, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _NewImageTile extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;

  const _NewImageTile({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(right: 10.w),
          width: 110.w,
          height: 110.h,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.r)),
          child: Image.file(file, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
