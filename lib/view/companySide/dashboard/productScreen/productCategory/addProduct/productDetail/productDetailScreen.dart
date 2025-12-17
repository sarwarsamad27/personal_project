import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/productDetail/productImage.dart';
import 'package:new_brand/viewModel/providers/productProvider/getSingleProduct_provider.dart';
import 'package:new_brand/widgets/productCard.dart';
import 'package:provider/provider.dart';

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

  List<Map<String, dynamic>> reviews = [
    {
      'user': 'Ali Khan',
      'rating': 5,
      'comment': 'Excellent product! The quality is top-notch.',
      'reply': '',
    },
    {
      'user': 'Sara Malik',
      'rating': 4,
      'comment': 'Loved it! But delivery took a bit long.',
      'reply': '',
    },
    {
      'user': 'Hassan Raza',
      'rating': 5,
      'comment': 'Perfect fit and great color.',
      'reply': '',
    },
    {
      'user': 'Fatima Noor',
      'rating': 3,
      'comment': 'Nice product but packaging could be better.',
      'reply': '',
    },
  ];
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetSingleProductProvider>(context);

    /// ---------------- NULL SAFE + LOADING ----------------
    if (provider.isLoading) {
      return const Center(child: SpinKitThreeBounce(
                  color: AppColor.primaryColor,
                  size: 30.0,
                ),);
    }

    if (provider.productData == null || provider.productData!.product == null) {
      return const Center(child: Text("No product data found"));
    }

    final prods = provider.productData!.product!;

    final relatedProducts = [
      {
        'name': 'Running Shoes',
        'price': 'PKR 4,999',
        'imageUrl':
            'https://i.pinimg.com/736x/60/a6/e2/60a6e2b0776d1d6735fce5ae7dc9b175.jpg',
      },
      {
        'name': 'Sneakers',
        'price': 'PKR 6,499',
        'imageUrl':
            'https://i.pinimg.com/736x/60/a6/e2/60a6e2b0776d1d6735fce5ae7dc9b175.jpg',
      },
      {
        'name': 'Sports Jacket',
        'price': 'PKR 8,999',
        'imageUrl':
            'https://i.pinimg.com/736x/60/a6/e2/60a6e2b0776d1d6735fce5ae7dc9b175.jpg',
      },
    ];

    final displayedReviews = showAllReviews
        ? reviews
        : reviews.take(3).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ---------------- PRODUCT IMAGE ----------------
                ProductImage(
                  imageUrls:  prods.images ?? [],
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

                /// ---------------- PRODUCT DETAILS ----------------
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 18.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// PRODUCT NAME
                      Text(
                        prods.name ?? "Unnamed Product",
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 8.h),

                      /// PRICE
                      Text(
                        prods.afterDiscountPrice != null
                            ? "PKR ${prods.afterDiscountPrice}"
                            : "Price Not Available",
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      Row(
                        children: [
                          _buildDetailChip(
                            'Color: ${(prods.color != null && prods.color!.isNotEmpty) ? prods.color!.first : "N/A"}',
                          ),
                          SizedBox(width: 8.w),
                          _buildDetailChip(
                            'Size: ${(prods.size != null && prods.size!.isNotEmpty) ? prods.size!.first : "N/A"}',
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 8.h),

                      Text(
                        prods.description ?? "No Description Available",
                        style: TextStyle(
                          color: Colors.grey[700],
                          height: 1.5,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                /// ---------------- REVIEWS (UNCHANGED) ----------------
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Customer Reviews",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10.h),

                      ...displayedReviews.map((review) {
                        return _buildReviewCard(review);
                      }),

                      if (reviews.length > 3)
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                showAllReviews = !showAllReviews;
                              });
                            },
                            child: Text(
                              showAllReviews ? "View Less" : "View More",
                              style: TextStyle(
                                color: AppColor.primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 15.sp,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                /// ---------------- RELATED PRODUCTS (UNCHANGED) ----------------
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    "Related Products",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                SizedBox(
                  height: 250.h,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    scrollDirection: Axis.horizontal,
                    itemCount: relatedProducts.length,
                    separatorBuilder: (_, __) => SizedBox(width: 12.w),
                    itemBuilder: (context, index) {
                      final item = relatedProducts[index];
                      return SizedBox(
                        width: 160.w,
                        child: ProductCard(
                          name: item['name']!,
                          price: item['price']!,
                          imageUrl: item['imageUrl']!,
                          onTap: () {},
                          description: '',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    TextEditingController replyController = TextEditingController(
      text: review['reply'],
    );

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review['user'],
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < review['rating'] ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 18.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            review['comment'],
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[800]),
          ),
          SizedBox(height: 10.h),

          // Seller Reply Section
          if (review['reply'].isNotEmpty)
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Seller Reply: ${review['reply']}",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13.sp,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editReplyDialog(review, replyController);
                      } else if (value == 'delete') {
                        setState(() {
                          review['reply'] = '';
                        });
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  _editReplyDialog(review, replyController);
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
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _editReplyDialog(
    Map<String, dynamic> review,
    TextEditingController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        title: const Text("Reply to Review"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Write your reply...",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                review['reply'] = controller.text;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
            ),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
