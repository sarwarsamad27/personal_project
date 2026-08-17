import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/productDetail/productDetailScreen.dart';
import 'package:new_brand/viewModel/providers/productProvider/getProductsByStock_provider.dart';
import 'package:new_brand/widgets/productCard.dart';
import 'package:provider/provider.dart';

// Drill-down for the dashboard's "Low Stock Products" / "Out of Stock
// Products" cards — same quantity thresholds the dashboard count and each
// ProductCard's own badge use (0 = out, 1-10 = low; see
// companyDashboard.js / product_controller.js's getProductsByStock).
class StockProductsScreen extends StatefulWidget {
  final String stockStatus; // "low" or "out"
  final String title;

  const StockProductsScreen({
    super.key,
    required this.stockStatus,
    required this.title,
  });

  @override
  State<StockProductsScreen> createState() => _StockProductsScreenState();
}

class _StockProductsScreenState extends State<StockProductsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<GetProductsByStockProvider>().fetchProducts(
        stockStatus: widget.stockStatus,
        refresh: true,
      );
    });
    _scrollController.addListener(() {
      final provider = context.read<GetProductsByStockProvider>();
      if (!_scrollController.hasClients) return;
      final position = _scrollController.position;
      if (position.pixels >= position.maxScrollExtent - 200 &&
          !provider.isLoading &&
          provider.hasMore) {
        provider.fetchProducts(stockStatus: widget.stockStatus);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.screenBgColor,
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<GetProductsByStockProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.products.isEmpty) {
            return Center(
              child: SpinKitThreeBounce(color: AppColor.primaryColor, size: 30),
            );
          }

          if (provider.products.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            color: AppColor.primaryColor,
            onRefresh: () => provider.fetchProducts(
              stockStatus: widget.stockStatus,
              refresh: true,
            ),
            child: GridView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(6.w, 14.h, 6.w, 30.h),
              itemCount:
                  provider.products.length + (provider.hasMore ? 2 : 0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 5,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                if (index >= provider.products.length) {
                  return Center(
                    child: SpinKitThreeBounce(
                      color: AppColor.primaryColor,
                      size: 22,
                    ),
                  );
                }
                final p = provider.products[index];
                return ProductCard(
                  name: p.name ?? "",
                  description: p.description ?? "",
                  price: "${p.afterDiscountPrice ?? 0}",
                  originalPrice: p.beforeDiscountPrice != null
                      ? "Rs. ${p.beforeDiscountPrice}"
                      : null,
                  imageUrl: (p.images != null && p.images!.isNotEmpty)
                      ? Global.getImageUrl(p.images!.first)
                      : "",
                  saveText: p.beforeDiscountPrice != null
                      ? "Save Rs.${(p.beforeDiscountPrice! - (p.afterDiscountPrice ?? 0)).abs()}"
                      : null,
                  stockQuantity: p.quantity,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(
                        productId: p.sId ?? '',
                        categoryId: p.categoryId ?? '',
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: 120.h),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.stockStatus == 'out'
                    ? Icons.remove_shopping_cart_outlined
                    : Icons.inventory_2_outlined,
                color: Colors.black26,
                size: 48.sp,
              ),
              SizedBox(height: 16.h),
              Text(
                widget.stockStatus == 'out'
                    ? "No Out of Stock Products"
                    : "No Low Stock Products",
                style: TextStyle(
                  color: AppColor.textPrimaryColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                "Products will show up here automatically",
                style: TextStyle(
                  color: AppColor.textSecondaryColor,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
