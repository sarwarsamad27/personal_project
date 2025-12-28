import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_brand/models/productModel/relatedProduct_model.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/productDetail/productImage.dart';
import 'package:new_brand/viewModel/providers/productProvider/getRelatedProduct_provider.dart';
import 'package:new_brand/viewModel/providers/productProvider/getSingleProduct_provider.dart';
import 'package:new_brand/viewModel/providers/reviewProvider/replyReview_provider.dart';
import 'package:new_brand/widgets/productCard.dart';
import 'package:provider/provider.dart';

import '../../../../../../../models/productModel/getSingleProduct_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final productId;
  final categoryId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.categoryId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool showAllReviews = false;
  Set<String> repliedReviews = {}; // Already replied reviews
  Map<String, bool> showReplyButton = {};

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final provider = Provider.of<GetSingleProductProvider>(
        context,
        listen: false,
      );

      final token = await LocalStorage.getToken() ?? "";

      await provider.fetchSingleProducts(
        token: token,
        categoryId: widget.categoryId,
        productId: widget.productId,
      );
      final relatedProvider = Provider.of<GetRelatedProductProvider>(
        context,
        listen: false,
      );

      await relatedProvider.fetchRelatedProducts(
        token: token,
        categoryId: widget.categoryId,
        productId: widget.productId,
      );
    });
  }

  String getEmailPrefix(String email) {
    if (email.contains("@")) {
      return email.split("@")[0];
    }
    return email;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetSingleProductProvider>(context);
    final relatedProvider = Provider.of<GetRelatedProductProvider>(context);

    /// ---------------- LOADING ----------------
    if (provider.isLoading) {
      return const Scaffold(
        body: Center(
          child: SpinKitThreeBounce(color: AppColor.primaryColor, size: 30),
        ),
      );
    }

    /// ---------------- NULL SAFE ----------------
    if (provider.productData == null || provider.productData!.product == null) {
      return const Scaffold(body: Center(child: Text("No product data found")));
    }

    final prods = provider.productData!.product!;
    final List<Reviews> reviews = provider.productData!.reviews ?? [];

    final displayedReviews = showAllReviews
        ? reviews
        : reviews.take(3).toList();
    final List<RelatedProducts> relatedProducts =
        relatedProvider.productData?.relatedProducts ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// IMAGE (unchanged)
              ProductImage(
                imageUrls: prods.images ?? [],
                name: prods.name ?? "",
                description: prods.description ?? "",
                color: (prods.color != null && prods.color!.isNotEmpty)
                    ? prods.color!.first
                    : "N/A",
                size: (prods.size != null && prods.size!.isNotEmpty)
                    ? prods.size!.first
                    : "N/A",
                price: "PKR ${prods.afterDiscountPrice ?? 0}",
                productId: prods.sId!,
                categoryId: prods.categoryId!,
              ),

              SizedBox(height: 12.h),

              /// DETAILS CARD (premium)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prods.name ?? "Unnamed Product",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 10.h),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            prods.afterDiscountPrice != null
                                ? "PKR ${prods.afterDiscountPrice}"
                                : "Price Not Available",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                              ),
                            ),
                            child: Text(
                              "In Stock",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1D4ED8),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 14.h),

                      Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: [
                          _buildMetaChip(
                            icon: Icons.palette_outlined,
                            text:
                                "Color: ${(prods.color != null && prods.color!.isNotEmpty) ? prods.color!.first : "N/A"}",
                          ),
                          _buildMetaChip(
                            icon: Icons.straighten_outlined,
                            text:
                                "Size: ${(prods.size != null && prods.size!.isNotEmpty) ? prods.size!.first : "N/A"}",
                          ),
                        ],
                      ),

                      SizedBox(height: 18.h),

                      _SectionTitle(title: "Description"),
                      SizedBox(height: 8.h),

                      Text(
                        prods.description ?? "No Description Available",
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.55,
                          color: const Color(0xFF4B5563),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 14.h),

              /// REVIEWS SECTION
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _SectionTitle(title: "Customer Reviews"),
              ),
              SizedBox(height: 8.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    ...displayedReviews.map(
                      (review) => _buildReviewCard(review),
                    ),
                    if (reviews.length > 3)
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            setState(() => showAllReviews = !showAllReviews);
                          },
                          child: Text(
                            showAllReviews ? "View Less" : "View More",
                            style: TextStyle(
                              color: AppColor.primaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              /// RELATED PRODUCTS
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _SectionTitle(title: "Related Products"),
              ),
              SizedBox(height: 10.h),

              SizedBox(
                height: 250.h,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  scrollDirection: Axis.horizontal,
                  itemCount: relatedProducts.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    final product = relatedProducts[index];
                    return SizedBox(
                      width: 190.w,
                      child: ProductCard(
                        name: product.name ?? "Unnamed Product",
                        price: product.afterDiscountPrice != null
                            ? "PKR ${product.afterDiscountPrice}"
                            : "Price N/A",
                        originalPrice: product.beforeDiscountPrice != null
                            ? "PKR ${product.beforeDiscountPrice}"
                            : null,
                        saveText: product.beforeDiscountPrice != null
                            ? "Save Rs.${(product.beforeDiscountPrice! - product.afterDiscountPrice!).abs()}"
                            : null,
                        description: product.description ?? "No Description",
                        imageUrl:
                            (product.images != null &&
                                product.images!.isNotEmpty)
                            ? Global.imageUrl + product.images!.first
                            : "",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(
                                productId: product.sId,
                                categoryId: product.categoryId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaChip({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: const Color(0xFF6B7280)),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _buildReviewCard(Reviews review) {
    final replyController = TextEditingController(
      text: review.reply?.text ?? "",
    );

    final userEmail = getEmailPrefix(review.userId?.email ?? "user");
    final reviewId = review.sId ?? "";

    showReplyButton.putIfAbsent(reviewId, () => true);

    final hasReply =
        review.reply != null && (review.reply!.text?.isNotEmpty ?? false);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A111827),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  (userEmail.isNotEmpty ? userEmail[0].toUpperCase() : "U"),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                    fontSize: 14.sp,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  userEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.sp,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < (review.stars ?? 0)
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 18.sp,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          Text(
            review.text ?? "",
            style: TextStyle(
              fontSize: 13.5.sp,
              height: 1.45,
              color: const Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 12.h),

          if (hasReply)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                "Author reply: ${review.reply!.text}",
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.45,
                  color: const Color(0xFF111827),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          if (!hasReply &&
              showReplyButton[reviewId]! &&
              !repliedReviews.contains(reviewId))
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  _replyDialog(review, replyController);

                  Future.delayed(const Duration(minutes: 1), () {
                    setState(() => showReplyButton[reviewId] = false);
                  });
                },
                icon: Icon(
                  Icons.reply,
                  size: 16.sp,
                  color: AppColor.primaryColor,
                ),
                label: Text(
                  "Reply",
                  style: TextStyle(
                    color: AppColor.primaryColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _replyDialog(Reviews review, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reply to Review"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Write your reply...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          Consumer<ReplyReviewProvider>(
            builder: (_, replyProvider, __) {
              return ElevatedButton(
                onPressed: replyProvider.isLoading
                    ? null
                    : () async {
                        final success = await replyProvider.replyOnReview(
                          reviewId: review.sId!,
                          replyText: controller.text,
                        );

                        if (success) {
                          // Mark as replied
                          setState(() {
                            repliedReviews.add(review.sId!);
                            showReplyButton[review.sId!] = false;
                          });

                          // Refresh product
                          final productProvider =
                              Provider.of<GetSingleProductProvider>(
                                context,
                                listen: false,
                              );

                          final token = await LocalStorage.getToken() ?? "";
                          await productProvider.fetchSingleProducts(
                            token: token,
                            categoryId: widget.categoryId,
                            productId: widget.productId,
                          );

                          Navigator.pop(context);
                        }
                      },
                child: replyProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save"),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  final Widget child;
  const _PremiumCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F111827),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        const Spacer(),
        Container(
          width: 36.w,
          height: 3.h,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}
