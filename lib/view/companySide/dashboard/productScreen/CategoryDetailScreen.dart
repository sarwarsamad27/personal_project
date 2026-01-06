import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/models/categoryModel/getCategory_model.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/addProductScreen.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/productDetail/productDetailScreen.dart';
import 'package:new_brand/viewModel/providers/productProvider/getProductCategoryWise_provider.dart';
import 'package:new_brand/widgets/productCard.dart';
import 'package:provider/provider.dart';

class CategoryProductsScreen extends StatefulWidget {
  final Categories category;
  const CategoryProductsScreen({Key? key, required this.category})
    : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final provider = Provider.of<GetProductCategoryWiseProvider>(
        context,
        listen: false,
      );

      await provider.fetchProducts(
        token: await LocalStorage.getToken() ?? "",
        categoryId: widget.category.sId!,
      );
    });
  }

  Future<void> _refreshProducts() async {
    final provider = Provider.of<GetProductCategoryWiseProvider>(
      context,
      listen: false,
    );

    await provider.fetchProducts(
      token: await LocalStorage.getToken() ?? "",
      categoryId: widget.category.sId!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final halfHeight = media.height * 0.5;

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: halfHeight,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  Global.imageUrl + widget.category.image!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: SpinKitThreeBounce(
                        color: AppColor.primaryColor,
                        size: 30.0,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported, size: 48),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.category.name!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Consumer<GetProductCategoryWiseProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(
                      child: SpinKitThreeBounce(
                        color: AppColor.primaryColor,
                        size: 30.0,
                      ),
                    );
                  }

                  if (provider.productData == null ||
                      provider.productData!.products == null ||
                      provider.productData!.products!.isEmpty) {
                    return const Center(child: Text("No products found"));
                  }

                  final prods = provider.productData!.products!;

                  // ✅ Optional: pull-to-refresh (premium UX)
                  return RefreshIndicator(
                    onRefresh: _refreshProducts,
                    child: GridView.builder(
                      padding: EdgeInsets.only(top: 12.h),
                      itemCount: prods.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                      itemBuilder: (context, index) {
                        final p = prods[index];

                        return ProductCard(
                          name: p.name ?? "",
                          description: p.description ?? "",
                          price: "Rs. ${p.afterDiscountPrice ?? 0}",
                          originalPrice: p.beforeDiscountPrice != null
                              ? "Rs. ${p.beforeDiscountPrice}"
                              : null,
                          imageUrl: (p.images != null && p.images!.isNotEmpty)
                              ? Global.imageUrl + p.images!.first
                              : "",
                          saveText: p.beforeDiscountPrice != null
                              ? "Save Rs.${(p.beforeDiscountPrice! - p.afterDiscountPrice!).abs()}"
                              : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(
                                  productId: p.sId ?? '',
                                  categoryId: p.categoryId ?? '',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

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
          onPressed: () async {
            // ✅ IMPORTANT: wait for AddProductScreen to close
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AddProductScreen(category: widget.category),
              ),
            );

            // ✅ Re-fetch immediately after returning
            await _refreshProducts();
          },
          child: const Icon(LucideIcons.plus, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

// To use this screen:
// Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryProductsScreen()));
