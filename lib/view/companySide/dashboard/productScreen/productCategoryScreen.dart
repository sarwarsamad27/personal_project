import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/CategoryDetailScreen.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/addProuctCategoryForm.dart';
import 'package:new_brand/widgets/productContainer.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
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

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
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

      // 🔹 Premium Body
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 240.h,
            crossAxisSpacing: 14.w,
            mainAxisSpacing: 14.h,
          ),
          itemBuilder: (context, index) {
            final item = categories[index];
            return CategoryTile(
              name: item["name"]!,
              image: item["image"]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryProductsScreen(),
                  ),
                );
              },
            );
          },
        ),
      ),

      // 🔹 Premium Floating Button
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
              MaterialPageRoute(builder: (context) => AddCategoryScreen()),
            );
          },
          child: const Icon(LucideIcons.plus, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
