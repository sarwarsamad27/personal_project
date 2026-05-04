import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_brand/models/productModel/relatedProduct_model.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/productDetail/widget/metaChip.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/productDetail/widget/premium_card.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/productDetail/widget/productImage.dart';
import 'package:new_brand/viewModel/providers/productProvider/getRelatedProduct_provider.dart';
import 'package:new_brand/viewModel/providers/productProvider/getSingleProduct_provider.dart';
import 'package:new_brand/viewModel/providers/reviewProvider/replyReview_provider.dart';
import 'package:new_brand/widgets/productCard.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

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
    return Consumer2<GetSingleProductProvider, GetRelatedProductProvider>(
      builder: (context, provider, relatedProvider, child) {
        /// ---------------- LOADING ----------------
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(
              child: SpinKitThreeBounce(color: AppColor.primaryColor, size: 30),
            ),
          );
        }

        /// ---------------- NULL SAFE ----------------
        if (provider.productData == null ||
            provider.productData!.product == null) {
          return const Scaffold(
            body: Center(child: Text("No product data found")),
          );
        }

        final prods = provider.productData!.product!;
        final List<Reviews> reviews = provider.productData!.reviews ?? [];

        final displayedReviews = provider.showAllReviews
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
                  // Jahan bhi ProductImage use ho raha hai wahan:
                  // ProductImage call fix karein - prods use karein, product nahi
                  ProductImage(
                    productId: prods.sId ?? '',
                    categoryId: widget.categoryId,
                    imageUrls: prods.images ?? [],
                    videoUrl: prods.videoUrl, // ✅ PASS VIDEO URL
                    name: prods.name ?? '',
                    description: prods.description ?? '',
                    color: prods.color?.join(',') ?? '',
                    size: prods.size?.join(',') ?? '',
                    price: prods.afterDiscountPrice?.toString() ?? '0',
                    quantity: prods.quantity ?? 0,
                    weightInGrams: prods.weightInGrams ?? 500,
                  ),
                  SizedBox(height: 12.h),

                  /// DETAILS CARD (premium)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: PremiumCard(
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

                          _buildQuantityRow(prods),

                          SizedBox(height: 14.h),

                          Wrap(
                            spacing: 10.w,
                            runSpacing: 10.h,
                            children: [
                              if (prods.color != null &&
                                  prods.color!.isNotEmpty)
                                buildMetaChip(
                                  icon: Icons.palette_outlined,
                                  text: "Color: ${prods.color!.first}",
                                ),

                              if (prods.size != null && prods.size!.isNotEmpty)
                                buildMetaChip(
                                  icon: Icons.straighten_outlined,
                                  text: "Size: ${prods.size!.first}",
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
                          (review) => buildReviewCard(review, provider),
                        ),
                        if (reviews.length > 3)
                          Align(
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: () {
                                provider.toggleShowAllReviews();
                              },
                              child: Text(
                                provider.showAllReviews
                                    ? "View Less"
                                    : "View More",
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
                                ? "PKR: ${product.afterDiscountPrice}"
                                : "Price N/A",
                            originalPrice: product.beforeDiscountPrice != null
                                ? "PKR ${product.beforeDiscountPrice}"
                                : null,
                            saveText: product.beforeDiscountPrice != null
                                ? "Save Rs.${(product.beforeDiscountPrice! - product.afterDiscountPrice!).abs()}"
                                : null,
                            description:
                                product.description ?? "No Description",
                            imageUrl:
                                (product.images != null &&
                                    product.images!.isNotEmpty)
                                ? Global.getImageUrl(product.images!.first)
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
      },
    );
  }

  Widget _buildQuantityRow(Product prods) {
    final int qty = prods.quantity ?? 0;
    final bool isOutOfStock = qty == 0;
    final bool isLowStock = qty > 0 && qty < 5;
    final bool isInStock = qty >= 5;

    // Colors based on stock level
    final Color bgColor = isOutOfStock
        ? const Color(0xFFFEE2E2)
        : isLowStock
        ? const Color(0xFFFFFBEB)
        : const Color(0xFFDCFCE7);

    final Color borderColor = isOutOfStock
        ? const Color(0xFFFCA5A5)
        : isLowStock
        ? const Color(0xFFFCD34D)
        : const Color(0xFF86EFAC);

    final Color textColor = isOutOfStock
        ? const Color(0xFFB91C1C)
        : isLowStock
        ? const Color(0xFF92400E)
        : const Color(0xFF15803D);

    final Color dotColor = isOutOfStock
        ? const Color(0xFFEF4444)
        : isLowStock
        ? const Color(0xFFF59E0B)
        : const Color(0xFF22C55E);

    final String label = isOutOfStock
        ? "Out of Stock"
        : isLowStock
        ? "Low Stock • $qty left"
        : "In Stock • $qty";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ✅ Price
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

        // ✅ Premium Stock Badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: dotColor.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Blinking dot
              _BlinkingDot(color: dotColor),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildReviewCard(Reviews review, GetSingleProductProvider provider) {
    final replyController = TextEditingController(
      text: review.reply?.text ?? "",
    );

    final userEmail = getEmailPrefix(review.userId?.email ?? "user");
    final reviewId = review.sId ?? "";

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

          // Review images
          if ((review.images?.isNotEmpty ?? false)) ...[
            SizedBox(height: 10.h),
            SizedBox(
              height: 80.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.images!.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () =>
                      _openFullscreenImages(context, review.images!, i),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      Global.getImageUrl(review.images![i]),
                      width: 80.w,
                      height: 80.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Review video
          if (review.video?.isNotEmpty ?? false) ...[
            SizedBox(height: 10.h),
            GestureDetector(
              onTap: () => _openFullscreenVideo(context, review.video!),
              child: _PdVideoThumb(url: review.video!),
            ),
          ],

          SizedBox(height: 12.h),

          // Seller reply block
          if (hasReply)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Author reply: ${review.reply!.text}",
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.45,
                      color: const Color(0xFF111827),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  // Reply images
                  if (review.reply!.images?.isNotEmpty ?? false) ...[
                    SizedBox(height: 8.h),
                    SizedBox(
                      height: 70.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: review.reply!.images!.length,
                        separatorBuilder: (_, __) => SizedBox(width: 6.w),
                        itemBuilder: (_, i) => GestureDetector(
                          onTap: () => _openFullscreenImages(
                            context,
                            review.reply!.images!,
                            i,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.r),
                            child: Image.network(
                              Global.getImageUrl(review.reply!.images![i]),
                              width: 70.w,
                              height: 70.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  // Reply video
                  if (review.reply!.video?.isNotEmpty ?? false) ...[
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: () =>
                          _openFullscreenVideo(context, review.reply!.video!),
                      child: _PdVideoThumb(url: review.reply!.video!),
                    ),
                  ],
                ],
              ),
            ),

          if (!hasReply &&
              (provider.showReplyButton[reviewId] ?? true) &&
              !provider.repliedReviews.contains(reviewId))
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  _replyDialog(review, replyController, provider);
                  Future.delayed(
                    const Duration(minutes: 1),
                    () => provider.setShowReplyButton(reviewId, false),
                  );
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

  void _openFullscreenImages(BuildContext ctx, List<String> urls, int idx) {
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => _PdFullscreenImages(urls: urls, initial: idx),
      ),
    );
  }

  void _openFullscreenVideo(BuildContext ctx, String url) {
    Navigator.push(
      ctx,
      MaterialPageRoute(builder: (_) => _PdFullscreenVideo(url: url)),
    );
  }

  void _replyDialog(
    Reviews review,
    TextEditingController controller,
    GetSingleProductProvider provider,
  ) {
    final List<File> replyImages = [];
    File? replyVideo;
    final picker = ImagePicker();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          scrollable: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text("Reply to Review"),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "Write your reply...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Photos Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Photos (${replyImages.length}/5)",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (replyImages.length < 5)
                        TextButton.icon(
                          onPressed: () async {
                            final picked = await picker.pickMultiImage(
                              imageQuality: 50,
                            );
                            if (picked.isNotEmpty) {
                              final add = picked
                                  .take(5 - replyImages.length)
                                  .map((x) => File(x.path))
                                  .toList();
                              setDialogState(() => replyImages.addAll(add));
                            }
                          },
                          icon: const Icon(Icons.add_a_photo, size: 18),
                          label: const Text("Add"),
                        ),
                    ],
                  ),

                  if (replyImages.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: replyImages.length,
                          itemBuilder: (_, i) => Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: FileImage(replyImages[i]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => setDialogState(
                                    () => replyImages.removeAt(i),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Video Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          replyVideo == null
                              ? "Video (optional)"
                              : "Video selected ✓",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (replyVideo == null)
                        TextButton.icon(
                          onPressed: () async {
                            final v = await picker.pickVideo(
                              source: ImageSource.gallery,
                              maxDuration: const Duration(seconds: 30),
                            );
                            if (v != null) {
                              setDialogState(() => replyVideo = File(v.path));
                            }
                          },
                          icon: const Icon(Icons.videocam, size: 18),
                          label: const Text("Add"),
                        ),
                      if (replyVideo != null)
                        TextButton(
                          onPressed: () =>
                              setDialogState(() => replyVideo = null),
                          child: const Text(
                            "Remove",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text("Cancel"),
            ),
            Consumer<ReplyReviewProvider>(
              builder: (_, replyProvider, __) => ElevatedButton(
                onPressed: replyProvider.isLoading
                    ? null
                    : () async {
                        debugPrint(
                          "🚀 Save clicked. Image count: ${replyImages.length}",
                        );
                        // Encode to base64
                        final b64Images = <String>[];
                        for (final img in replyImages) {
                          final bytes = await img.readAsBytes();
                          b64Images.add(
                            "data:image/jpg;base64,${base64Encode(bytes)}",
                          );
                        }
                        String? b64Video;
                        if (replyVideo != null) {
                          final bytes = await replyVideo!.readAsBytes();
                          b64Video =
                              "data:video/mp4;base64,${base64Encode(bytes)}";
                        }

                        debugPrint(
                          "📤 Sending reply with ${b64Images.length} images",
                        );
                        final success = await replyProvider.replyOnReview(
                          reviewId: review.sId!,
                          replyText: controller.text,
                          replyImages: b64Images,
                          replyVideo: b64Video,
                        );

                        if (success) {
                          provider.markAsReplied(review.sId!);
                          final token = await LocalStorage.getToken() ?? "";
                          await provider.fetchSingleProducts(
                            token: token,
                            categoryId: widget.categoryId,
                            productId: widget.productId,
                          );
                          if (dialogCtx.mounted) {
                            Navigator.pop(dialogCtx);
                          }
                        }
                      },
                child: replyProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Video thumbnail widget ────────────────────────────────────────────────────
class _PdVideoThumb extends StatefulWidget {
  final String url;
  const _PdVideoThumb({required this.url});
  @override
  State<_PdVideoThumb> createState() => _PdVideoThumbState();
}

class _PdVideoThumbState extends State<_PdVideoThumb> {
  late VideoPlayerController _ctrl;
  bool _ready = false;
  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) setState(() => _ready = true);
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    height: 110.h,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        if (_ready)
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: AspectRatio(
              aspectRatio: _ctrl.value.aspectRatio,
              child: VideoPlayer(_ctrl),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        const Icon(Icons.play_circle_fill, color: Colors.white, size: 44),
      ],
    ),
  );
}

// ── Fullscreen image viewer ──────────────────────────────────────────────────
class _PdFullscreenImages extends StatefulWidget {
  final List<String> urls;
  final int initial;
  const _PdFullscreenImages({required this.urls, required this.initial});
  @override
  State<_PdFullscreenImages> createState() => _PdFullscreenImagesState();
}

class _PdFullscreenImagesState extends State<_PdFullscreenImages> {
  late PageController _page;
  late int _cur;
  @override
  void initState() {
    super.initState();
    _cur = widget.initial;
    _page = PageController(initialPage: widget.initial);
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      title: Text("${_cur + 1} / ${widget.urls.length}"),
    ),
    body: PageView.builder(
      controller: _page,
      itemCount: widget.urls.length,
      onPageChanged: (i) => setState(() => _cur = i),
      itemBuilder: (_, i) => InteractiveViewer(
        child: Center(
          child: Image.network(
            Global.getImageUrl(widget.urls[i]),
            fit: BoxFit.contain,
            loadingBuilder: (_, c, p) => p == null
                ? c
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.broken_image, color: Colors.white54, size: 60),
          ),
        ),
      ),
    ),
  );
}

// ── Fullscreen video player ──────────────────────────────────────────────────
class _PdFullscreenVideo extends StatefulWidget {
  final String url;
  const _PdFullscreenVideo({required this.url});
  @override
  State<_PdFullscreenVideo> createState() => _PdFullscreenVideoState();
}

class _PdFullscreenVideoState extends State<_PdFullscreenVideo> {
  late VideoPlayerController _ctrl;
  bool _ready = false;
  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _ready = true);
          _ctrl.play();
        }
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    body: Center(
      child: _ready
          ? GestureDetector(
              onTap: () {
                _ctrl.value.isPlaying ? _ctrl.pause() : _ctrl.play();
                setState(() {});
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _ctrl.value.aspectRatio,
                    child: VideoPlayer(_ctrl),
                  ),
                  if (!_ctrl.value.isPlaying)
                    const Icon(
                      Icons.play_circle_fill,
                      color: Colors.white70,
                      size: 64,
                    ),
                ],
              ),
            )
          : const CircularProgressIndicator(color: Colors.white),
    ),
  );
}

class _BlinkingDot extends StatefulWidget {
  final Color color;
  const _BlinkingDot({required this.color});

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 8.w,
        height: 8.w,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.5),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
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
