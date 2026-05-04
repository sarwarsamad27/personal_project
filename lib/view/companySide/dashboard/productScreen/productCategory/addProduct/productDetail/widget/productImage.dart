import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/productDetail/widget/delete_product_dialog.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/productDetail/widget/edit_product_dialog.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';

class ProductImage extends StatefulWidget {
  final List<String> imageUrls;
  final String? videoUrl;
  final String name;
  final String description;
  final String color;
  final String size;
  final String price;
  final String categoryId;
  final String productId;
  final int quantity;
  final int weightInGrams;

  const ProductImage({
    super.key,
    required this.imageUrls,
    this.videoUrl,
    required this.name,
    required this.productId,
    required this.description,
    required this.color,
    required this.size,
    required this.price,
    required this.categoryId,
    required this.quantity,
    required this.weightInGrams,
  });

  @override
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  final PageController _pageController = PageController();

  // ── Video controller initialised once in initState ──────────────────────────
  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final url = widget.videoUrl?.trim();
    if (url == null || url.isEmpty) return;
    _videoCtrl = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await _videoCtrl!.initialize();
      if (mounted) setState(() => _videoReady = true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoCtrl?.dispose();
    super.dispose();
  }

  void _deleteProduct(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => DeleteProductDialog(productId: widget.productId),
    );
  }

  void _editProduct(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditProductDialog(
        productId: widget.productId,
        categoryId: widget.categoryId,
        imageUrls: widget.imageUrls,
        videoUrl: widget.videoUrl,
        name: widget.name,
        description: widget.description,
        color: widget.color,
        size: widget.size,
        price: widget.price,
        quantity: widget.quantity,
        weightInGrams: widget.weightInGrams,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> validImages = widget.imageUrls
        .where((e) => e.trim().isNotEmpty)
        .toList();

    final bool hasVideo =
        widget.videoUrl != null && widget.videoUrl!.trim().isNotEmpty;
    final int itemCount = validImages.length + (hasVideo ? 1 : 0);

    return SizedBox(
      height: 0.45.sh,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // ---------- MEDIA CAROUSEL ----------
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24.r),
              bottomRight: Radius.circular(24.r),
            ),
            child: itemCount > 0
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: itemCount,
                    onPageChanged: (i) {
                      // Pause video when swiping away from it
                      if (i < validImages.length) _videoCtrl?.pause();
                    },
                    itemBuilder: (context, index) {
                      if (index < validImages.length) {
                        final url = Global.getImageUrl(validImages[index]);
                        return Image.network(
                          url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) =>
                              const _NoImagePlaceholder(),
                        );
                      } else {
                        // Pass pre-initialised controller — no re-fetch on swipe
                        return _ProductVideoPlayer(
                          controller: _videoCtrl,
                          isReady: _videoReady,
                        );
                      }
                    },
                  )
                : const _NoImagePlaceholder(),
          ),

          // ---------- INDICATOR ----------
          if (itemCount > 1)
            Positioned(
              bottom: 16.h,
              child: SmoothPageIndicator(
                controller: _pageController,
                count: itemCount,
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

// ── Video player — receives pre-initialised controller, no re-init on rebuild ──
class _ProductVideoPlayer extends StatefulWidget {
  final VideoPlayerController? controller;
  final bool isReady;

  const _ProductVideoPlayer({
    required this.controller,
    required this.isReady,
  });

  @override
  State<_ProductVideoPlayer> createState() => _ProductVideoPlayerState();
}

class _ProductVideoPlayerState extends State<_ProductVideoPlayer> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onUpdate);
  }

  @override
  void didUpdateWidget(_ProductVideoPlayer old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller?.removeListener(_onUpdate);
      widget.controller?.addListener(_onUpdate);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;

    if (!widget.isReady || ctrl == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isPlaying = ctrl.value.isPlaying;

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: ctrl.value.aspectRatio,
          child: VideoPlayer(ctrl),
        ),
        GestureDetector(
          onTap: () => isPlaying ? ctrl.pause() : ctrl.play(),
          child: CircleAvatar(
            backgroundColor: Colors.black26,
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

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
