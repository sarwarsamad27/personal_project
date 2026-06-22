import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/widgets/blinking_badge.dart'; // Add this import

/// ✅ Reusable custom category tile widget
class CategoryTile extends StatelessWidget {
  final String name;
  final String image;
  final VoidCallback onTap;
  final bool? hasLowStock;
  final bool? hasOutOfStock;
  final bool isPendingSync;

  const CategoryTile({
    required this.name,
    required this.image,
    required this.onTap,
    this.hasLowStock,
    this.hasOutOfStock,
    this.isPendingSync = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🖼️ Full Image Container
          Container(
            height: 170.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18.r),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: image.startsWith('http')
                        ? Image.network(image, fit: BoxFit.cover)
                        : Image.file(File(image), fit: BoxFit.cover),
                  ),
                  // gradient overlay for effect
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.15),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // out of stock / low stock blink
                  if (hasOutOfStock == true)
                    Positioned(
                      bottom: 8.h,
                      left: 6.w,
                      child: BlinkingBadge(text: "Out of Stock", isError: true),
                    )
                  else if (hasLowStock == true)
                    Positioned(
                      bottom: 8.h,
                      left: 6.w,
                      child: BlinkingBadge(
                        text: "Low Stock Items",
                        isError: false,
                      ),
                    ),
                  // small favorite button (optional)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        LucideIcons.heart,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                  if (isPendingSync)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade800,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Syncing…",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 🔹 Name below container (custom look)
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: AppColor.primaryColor.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.textPrimaryColor,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
