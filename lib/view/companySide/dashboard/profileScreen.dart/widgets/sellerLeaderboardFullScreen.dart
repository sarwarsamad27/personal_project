import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/models/leaderboard/getLeaderboard_model.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/viewModel/providers/leaderboardProvider/getLeaderboard_provider.dart';
import 'package:provider/provider.dart';

/// Full "Top Sellers" list — search by name, paginated (loads more as you
/// scroll near the bottom) so a large seller base never has to render or
/// download in one shot.
class SellerLeaderboardFullScreen extends StatefulWidget {
  final String? myProfileId;
  const SellerLeaderboardFullScreen({super.key, this.myProfileId});

  @override
  State<SellerLeaderboardFullScreen> createState() =>
      _SellerLeaderboardFullScreenState();
}

class _SellerLeaderboardFullScreenState
    extends State<SellerLeaderboardFullScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GetLeaderboardProvider>().loadFullListFirstPage();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      context.read<GetLeaderboardProvider>().loadMoreFullList();
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<GetLeaderboardProvider>().loadFullListFirstPage(
        search: query,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Top Sellers",
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(14.w),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Search seller by name...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<GetLeaderboardProvider>().loadFullListFirstPage();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<GetLeaderboardProvider>(
              builder: (context, provider, _) {
                if (provider.isLoadingFullList) {
                  return const Center(
                    child: SpinKitThreeBounce(
                      color: AppColor.primaryColor,
                      size: 24,
                    ),
                  );
                }

                if (provider.fullListError != null) {
                  return Center(
                    child: Text(
                      provider.fullListError!,
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                    ),
                  );
                }

                if (provider.fullList.isEmpty) {
                  return Center(
                    child: Text(
                      "No sellers found",
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                    ),
                  );
                }

                return ListView.separated(
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 20.h),
                  itemCount:
                      provider.fullList.length + (provider.hasMore ? 1 : 0),
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    if (index >= provider.fullList.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: const Center(
                          child: SpinKitThreeBounce(
                            color: AppColor.primaryColor,
                            size: 18,
                          ),
                        ),
                      );
                    }
                    final seller = provider.fullList[index];
                    return _SellerRow(
                      seller: seller,
                      isMe: widget.myProfileId != null &&
                          seller.profileId == widget.myProfileId,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeStyle {
  final List<Color> gradient;
  final Color iconColor;
  const _BadgeStyle({required this.gradient, required this.iconColor});
}

const _badgeStyles = {
  "gold": _BadgeStyle(
    gradient: [Color(0xFFFFE9A8), Color(0xFFD4AF37)],
    iconColor: Color(0xFF8A6A00),
  ),
  "silver": _BadgeStyle(
    gradient: [Color(0xFFEDEDED), Color(0xFFB8B8B8)],
    iconColor: Color(0xFF5A5A5A),
  ),
  "bronze": _BadgeStyle(
    gradient: [Color(0xFFE7B98A), Color(0xFFAD6F3B)],
    iconColor: Color(0xFF5C3A19),
  ),
};

class _SellerRow extends StatelessWidget {
  final SellerRank seller;
  final bool isMe;
  const _SellerRow({required this.seller, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final badgeStyle = _badgeStyles[seller.badge];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isMe ? AppColor.primaryColor.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isMe
              ? AppColor.primaryColor.withOpacity(0.4)
              : Colors.grey.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          badgeStyle != null
              ? Container(
                  width: 34.r,
                  height: 34.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: badgeStyle.gradient,
                    ),
                  ),
                  child: Icon(
                    LucideIcons.crown,
                    color: badgeStyle.iconColor,
                    size: 17.sp,
                  ),
                )
              : Container(
                  width: 34.r,
                  height: 34.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.12),
                  ),
                  child: Text(
                    "${seller.rank}",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          SizedBox(width: 12.w),
          CircleAvatar(
            radius: 18.r,
            backgroundColor: Colors.grey.withOpacity(0.12),
            backgroundImage: seller.image != null
                ? NetworkImage(Global.getImageUrl(seller.image))
                : const NetworkImage("https://i.pravatar.cc/300"),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        seller.name ?? "Seller",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (isMe) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          "You",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  "${seller.deliveredOrders ?? 0} orders delivered",
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
