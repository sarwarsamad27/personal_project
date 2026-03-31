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
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    final imageHeight = media.height * 0.48.h;
    // Parallax: image moves up slower than scroll
    final parallaxOffset = _scrollOffset * 0.45;

    return Scaffold(
      body: Stack(
        children: [
          // ── Scrollable content ──
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero image with parallax ──
              SliverToBoxAdapter(
                child: SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: ClipRect(
                    child: OverflowBox(
                      maxHeight: imageHeight + 120.h,
                      alignment: Alignment.topCenter,
                      child: Transform.translate(
                        offset: Offset(0, -parallaxOffset),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // ── Image ──
                            Image.network(
                              Global.getImageUrl(widget.category.image!),
                              fit: BoxFit.cover,
                              height: imageHeight + 120.h,
                              width: double.infinity,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: SpinKitThreeBounce(
                                    color: AppColor.primaryColor,
                                    size: 30.0,
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[900],
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 48.sp,
                                  color: Colors.white30,
                                ),
                              ),
                            ),

                            // ── Premium gradient overlay (bottom heavy) ──
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [0.0, 0.45, 0.75, 1.0],
                                  colors: [
                                    Colors.black.withOpacity(0.15),
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.55),
                                    Colors.black.withOpacity(0.88),
                                  ],
                                ),
                              ),
                            ),

                            // ── Back button ──
                            Positioned(
                              top: MediaQuery.of(context).padding.top + 8.h,
                              left: 12.w,
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.35),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white24,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 18.sp,
                                  ),
                                ),
                              ),
                            ),

                            // ── Category name + tag ──
                            Positioned(
                              left: 20.w,
                              right: 20.w,
                              bottom: 22.h,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.category.name!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32.sp,
                                      fontWeight: FontWeight.bold,
                                      height: 1.1,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.6),
                                          blurRadius: 12,
                                          offset: const Offset(0, 2),
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
                    ),
                  ),
                ),
              ),

              // ── Products grid ──
              Consumer<GetProductCategoryWiseProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: SpinKitThreeBounce(
                          color: AppColor.primaryColor,
                          size: 30.0,
                        ),
                      ),
                    );
                  }

                  if (provider.productData == null ||
                      provider.productData!.products == null ||
                      provider.productData!.products!.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          "No products found",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    );
                  }

                  final prods = provider.productData!.products!;

                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(6.w, 14.h, 6.w, 100.h),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 5,
                            childAspectRatio: 0.72,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final p = prods[index];
                        return ProductCard(
                          name: p.name ?? "",
                          description: p.description ?? "",
                          price: "Rs. ${p.afterDiscountPrice ?? 0}",
                          originalPrice: p.beforeDiscountPrice != null
                              ? "Rs. ${p.beforeDiscountPrice}"
                              : null,
                          imageUrl: (p.images != null && p.images!.isNotEmpty)
                              ? Global.getImageUrl(p.images!.first)
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
                      }, childCount: prods.length),
                    ),
                  );
                },
              ),
            ],
          ),

          // ── FAB ──
          Positioned(
            bottom: 24,
            right: 20,
            child: Container(
              height: 62.h,
              width: 62.h,
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
                    color: AppColor.primaryColor.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddProductScreen(category: widget.category),
                    ),
                  );
                  await _refreshProducts();
                },
                child: const Icon(
                  LucideIcons.plus,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
