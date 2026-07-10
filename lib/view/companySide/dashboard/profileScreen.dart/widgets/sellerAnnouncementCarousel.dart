import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = PageController();
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
        SizedBox(
          height: 150.h,
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
                      : AppColor.primaryColor.withOpacity(0.25),
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
            color: gradient.last.withOpacity(0.35),
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
                color: Colors.white.withOpacity(0.12),
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
                      color: Colors.white.withOpacity(0.22),
                    ),
                    child: Icon(icon, color: Colors.white, size: 19.sp),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      card.title ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: Text(
                  card.description ?? "",
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 12.5.sp,
                    height: 1.4,
                  ),
                ),
              ),
              if (card.eventDate != null) ...[
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
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
