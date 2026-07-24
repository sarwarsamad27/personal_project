import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/productDetail/productDetailScreen.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import '../../../../../models/review/getAllReview_model.dart';

class UserReviewsScreen extends StatelessWidget {
  final List<Data> reviews;
  const UserReviewsScreen({super.key, required this.reviews});

  String getEmailPrefix(String email) =>
      email.contains("@") ? email.split("@")[0] : email;

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "";
    try {
      return DateFormat("dd MMM yyyy").format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }

  List<Widget> buildStars(int count) => List.generate(
    5,
    (i) => Icon(
      Icons.star,
      color: i < count ? Colors.amber : Colors.white30,
      size: 18.sp,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Reviews",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColor.primaryColor,
      ),
      body: CustomBgContainer(
        child: Padding(
          padding: EdgeInsets.all(15.w),
          child: ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              final userEmail = getEmailPrefix(review.user?.email ?? "user");
              final hasImages = (review.images?.isNotEmpty ?? false);
              final hasVideo = review.video?.isNotEmpty ?? false;

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(
                        productId: review.product?.productId ?? "",
                        categoryId: review.product?.category?.categoryId ?? "",
                      ),
                    ),
                  ),
                  child: CustomAppContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16.r,
                              backgroundColor: Colors.orange,
                              child: Text(
                                userEmail[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userEmail,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(children: buildStars(review.stars ?? 0)),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              formatDate(review.createdAt),
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        if ((review.text ?? "").isNotEmpty)
                          Text(
                            review.text ?? "",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                          ),

                        // Review images
                        if (hasImages) ...[
                          SizedBox(height: 10.h),
                          SizedBox(
                            height: 70.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: review.images!.length,
                              separatorBuilder: (_, __) => SizedBox(width: 6.w),
                              itemBuilder: (_, i) => GestureDetector(
                                onTap: () =>
                                    _openFullscreen(context, review.images!, i),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6.r),
                                  child: Image.network(
                                    Global.getImageUrl(review.images![i]),
                                    width: 70.w,
                                    height: 70.h,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 70.w,
                                      height: 70.h,
                                      color: Colors.white12,
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.white38,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],

                        // Review video
                        if (hasVideo) ...[
                          SizedBox(height: 10.h),
                          GestureDetector(
                            onTap: () => _openVideo(context, review.video!),
                            child: _VideoThumb(url: review.video!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _openFullscreen(BuildContext ctx, List<String> urls, int idx) {
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => _FullscreenImages(urls: urls, initial: idx),
      ),
    );
  }

  void _openVideo(BuildContext ctx, String url) {
    Navigator.push(
      ctx,
      MaterialPageRoute(builder: (_) => _FullscreenVideoScreen(url: url)),
    );
  }
}

// ── Video thumbnail ──────────────────────────────────────────────────────────
class _VideoThumb extends StatefulWidget {
  final String url;
  const _VideoThumb({required this.url});
  @override
  State<_VideoThumb> createState() => _VideoThumbState();
}

class _VideoThumbState extends State<_VideoThumb> {
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
    height: 100.h,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        if (_ready)
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: AspectRatio(
              aspectRatio: _ctrl.value.aspectRatio,
              child: VideoPlayer(_ctrl),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        const Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
      ],
    ),
  );
}

// ── Fullscreen image viewer ──────────────────────────────────────────────────
class _FullscreenImages extends StatefulWidget {
  final List<String> urls;
  final int initial;
  const _FullscreenImages({required this.urls, required this.initial});
  @override
  State<_FullscreenImages> createState() => _FullscreenImagesState();
}

class _FullscreenImagesState extends State<_FullscreenImages> {
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

// ── Fullscreen video ─────────────────────────────────────────────────────────
class _FullscreenVideoScreen extends StatefulWidget {
  final String url;
  const _FullscreenVideoScreen({required this.url});
  @override
  State<_FullscreenVideoScreen> createState() => _FullscreenVideoScreenState();
}

class _FullscreenVideoScreenState extends State<_FullscreenVideoScreen> {
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
