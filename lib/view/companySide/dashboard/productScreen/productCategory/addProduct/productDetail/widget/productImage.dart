import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/productDetail/widget/delete_product_dialog.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/productDetail/widget/edit_product_dialog.dart';
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
  final String? stock;

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
    this.stock,
  });

  final PageController _pageController = PageController();

  void _deleteProduct(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => DeleteProductDialog(productId: productId),
    );
  }

  void _editProduct(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditProductDialog(
        productId: productId,
        categoryId: categoryId,
        imageUrls: imageUrls,
        name: name,
        description: description,
        color: color,
        size: size,
        price: price,
        stock: stock ?? "In Stock",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1) Empty/blank paths remove
    final List<String> validImages = imageUrls
        .where((e) => e.trim().isNotEmpty)
        .toList();

    // 2) Base URL safety (optional but helpful)
    final String baseUrl = (Global.imageUrl).trim();

    // If baseUrl is empty, we should not attempt network load.
    final bool canLoadNetwork = baseUrl.isNotEmpty;

    final bool hasImages = validImages.isNotEmpty && canLoadNetwork;

    return SizedBox(
      height: 0.45.sh,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // ---------- IMAGE / PLACEHOLDER ----------
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24.r),
              bottomRight: Radius.circular(24.r),
            ),
            child: hasImages
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: validImages.length,
                    itemBuilder: (context, index) {
                      final url = baseUrl + validImages[index];

                      return Image.network(
                        url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) =>
                            const _NoImagePlaceholder(),
                      );
                    },
                  )
                : const _NoImagePlaceholder(),
          ),

          // ---------- INDICATOR (only if images) ----------
          if (hasImages)
            Positioned(
              bottom: 16.h,
              child: SmoothPageIndicator(
                controller: _pageController,
                count: validImages.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: Colors.black,
                  dotColor: Colors.grey[400]!,
                  dotHeight: 8.h,
                  dotWidth: 8.w,
                  spacing: 6.w,
                ),
              ),
            ),

          // ---------- BACK ----------
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

          // ---------- ACTIONS ----------
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

/// Simple placeholder widget
class _NoImagePlaceholder extends StatelessWidget {
  const _NoImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 60,
        color: Colors.grey.shade600,
      ),
    );
  }
}
