import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/models/productModel/productCard_model.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';

class ProductCardWidget extends StatelessWidget {
  final ProductCard productCard;
  final bool isMe;

  const ProductCardWidget({
    super.key,
    required this.productCard,
    required this.isMe,
  });

  @override
  @override
  Widget build(BuildContext context) {
    // ✅ Image URL fix helper
    String getImageUrl(String? path) {
      if (path == null || path.isEmpty) return '';
      if (path.startsWith('http')) return path;
      return '${Global.imageUrl}$path';
    }

    return Container(
      margin: EdgeInsets.only(
        bottom: 8.h,
        left: isMe ? 60.w : 0,
        right: isMe ? 0 : 60.w,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 18.sp,
                    color: AppColor.primaryColor,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "Product Inquiry",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // ✅ IMAGE + DETAILS ROW
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Product Image
                  if (productCard.productImage != null &&
                      productCard.productImage!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.network(
                        getImageUrl(productCard.productImage),
                        width: 80.w,
                        height: 80.w,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.image_outlined,
                            size: 32.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ),

                  SizedBox(width: 12.w),

                  // ✅ Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productCard.productName ?? 'Product',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          productCard.brandName ?? 'Brand',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        if (productCard.productDescription != null &&
                            productCard.productDescription!.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text(
                            productCard.productDescription!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF6B7280),
                              height: 1.4,
                            ),
                          ),
                        ],
                        SizedBox(height: 8.h),
                        // Price Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColor.primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            "Rs: ${productCard.productPrice ?? '0'}",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColor.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
