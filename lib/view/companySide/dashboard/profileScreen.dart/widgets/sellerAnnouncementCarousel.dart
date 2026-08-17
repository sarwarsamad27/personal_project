import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:new_brand/models/sellerAnnouncement/getSellerAnnouncement_model.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/viewModel/providers/sellerAnnouncementProvider/getSellerAnnouncement_provider.dart';
import 'package:provider/provider.dart';

const Map<String, IconData> _kAnnouncementIcons = {
  'gift': LucideIcons.gift,
  'megaphone': LucideIcons.megaphone,
  'star': LucideIcons.star,
  'trophy': LucideIcons.trophy,
  'sparkles': LucideIcons.sparkles,
  'bell': LucideIcons.bell,
  'calendar': LucideIcons.calendar,
  'heart': LucideIcons.heart,
};

const Map<String, List<Color>> _kTypeGradients = {
  // Gold — matches the leaderboard's #1 crown color, ties gift cards to
  // the same "premium reward" visual language used elsewhere in the app.
  'gift': [Color(0xFFF6D365), Color(0xFFB8860B)],
  'announcement': [Color(0xFF7F7FD5), Color(0xFF4B4BC4)],
  'general': [Color(0xFFdf762e), Color(0xFFb85c18)],
};

/// Admin-authored rotating card carousel (gifts, announcements, general
/// messages) shown on the seller's profile screen. Every visible field —
/// title, description, icon, color theme, and an optional event date (e.g.
/// an annual top-seller gift) — is entirely controlled from the admin app;
/// nothing here is hardcoded.
class SellerAnnouncementCarousel extends StatelessWidget {
  const SellerAnnouncementCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      if (!context.mounted) return;
      context.read<GetSellerAnnouncementProvider>().getAnnouncementsOnce();
    });

    return Consumer<GetSellerAnnouncementProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && !provider.isFetched) {
          return SizedBox(
            height: 150.h,
            child: const Center(
              child: SpinKitThreeBounce(color: AppColor.whiteColor, size: 24.0),
            ),
          );
        }

        final cards = provider.announcementData?.announcements ?? [];
        if (cards.isEmpty) return const SizedBox.shrink();

        return _RotatingCards(cards: cards);
      },
    );
  }
}

class _RotatingCards extends StatefulWidget {
  final List<SellerAnnouncement> cards;
  const _RotatingCards({required this.cards});

  @override
  State<_RotatingCards> createState() => _RotatingCardsState();
}

class _RotatingCardsState extends State<_RotatingCards> {
  late final PageController _controller;
  Timer? _timer;
  int _page = 0;

  // A fixed height (the old 150.h) clips whenever a card's real title +
  // description needs more room than that guess — worse on some phones
  // than others since line-wrap count depends on actual screen width.
  // Instead, every card is laid out once off-screen (real widgets, real
  // text metrics — not a hand-rolled character/line estimate) so the
  // carousel can size itself to whichever card is tallest.
  List<GlobalKey> _measureKeys = [];
  double? _measuredHeight;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _measureKeys = List.generate(widget.cards.length, (_) => GlobalKey());
    _startAutoRotate();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureHeights());
  }

  @override
  void didUpdateWidget(covariant _RotatingCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cards.length != widget.cards.length) {
      _measureKeys = List.generate(widget.cards.length, (_) => GlobalKey());
      _measuredHeight = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureHeights());
    }
  }

  void _startAutoRotate() {
    _timer?.cancel();
    if (widget.cards.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!_controller.hasClients) return;
        final next = (_page + 1) % widget.cards.length;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      });
    }
  }

  void _measureHeights() {
    if (!mounted) return;
    double tallest = 0;
    for (final key in _measureKeys) {
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize && box.size.height > tallest) {
        tallest = box.size.height;
      }
    }
    if (tallest > 0 && tallest != _measuredHeight) {
      setState(() => _measuredHeight = tallest);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Offstage measurement pass — laid out (so real sizes are
        // available) but not painted/hit-tested, and takes no space in
        // this Column. Runs again only when the card list itself changes
        // (see didUpdateWidget), not on every rebuild.
        if (_measuredHeight == null)
          Offstage(
            child: Column(
              children: [
                for (int i = 0; i < widget.cards.length; i++)
                  Padding(
                    key: _measureKeys[i],
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: _AnnouncementCard(card: widget.cards[i]),
                  ),
              ],
            ),
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _measuredHeight ?? 150.h,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.cards.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: _AnnouncementCard(card: widget.cards[index]),
            ),
          ),
        ),
        if (widget.cards.length > 1) ...[
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.cards.length, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: active ? 18.w : 6.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: active
                      ? AppColor.primaryColor
                      : AppColor.primaryColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final SellerAnnouncement card;
  const _AnnouncementCard({required this.card});

  @override
  Widget build(BuildContext context) {
    final gradient = _kTypeGradients[card.type] ?? _kTypeGradients['general']!;
    final icon = _kAnnouncementIcons[card.icon] ?? LucideIcons.megaphone;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Premium shine overlay, matches the followers-card treatment
          // elsewhere on this screen.
          Positioned(
            top: -30.h,
            right: -30.w,
            child: Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                    child: Icon(icon, color: Colors.white, size: 19.sp),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      card.title ?? "",
                      // Admin's title field is capped at 40 characters
                      // (see adminSide's seller_announcement_management_screen.dart)
                      // specifically so it always fits within 2 lines —
                      // maxLines/ellipsis here is only a defensive ceiling
                      // for older data saved before that cap existed.
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                card.description ?? "",
                // Admin's description field is capped at 150 characters —
                // same reasoning as the title's maxLines above.
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: 12.5.sp,
                  height: 1.4,
                ),
              ),
              if (card.eventDate != null) ...[
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.calendar, color: Colors.white, size: 12.sp),
                      SizedBox(width: 5.w),
                      Text(
                        DateFormat('dd MMM yyyy').format(card.eventDate!),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
