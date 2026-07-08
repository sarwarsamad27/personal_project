import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/models/leaderboard/getLeaderboard_model.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/viewModel/providers/leaderboardProvider/getLeaderboard_provider.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:provider/provider.dart';

/// Public "Top Sellers" leaderboard — ranked by lifetime delivered orders.
/// Rank #1-3 get a gold/silver/bronze crown, but only once that seller has
/// crossed [GetLeaderboardModel.badgeThreshold] delivered orders — a bare
/// top-3 spot with a low order count still shows a plain rank number.
class SellerLeaderboard extends StatelessWidget {
  final String? myProfileId;

  const SellerLeaderboard({super.key, this.myProfileId});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      context.read<GetLeaderboardProvider>().getLeaderboardOnce();
    });

    return Consumer<GetLeaderboardProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && !provider.isFetched) {
          return const Center(
            child: SpinKitThreeBounce(color: AppColor.whiteColor, size: 24.0),
          );
        }

        final entries = provider.leaderboardData?.leaderboard ?? [];
        if (entries.isEmpty) return const SizedBox.shrink();

        final threshold = provider.leaderboardData?.badgeThreshold ?? 500;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "🏆 Top Sellers",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              "Ranked by delivered orders • cross $threshold+ to earn a crown",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11.sp,
              ),
            ),
            SizedBox(height: 12.h),
            ...entries.map(
              (seller) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _LeaderboardRow(
                  seller: seller,
                  isMe: myProfileId != null && seller.profileId == myProfileId,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BadgeStyle {
  final List<Color> gradient;
  final Color iconColor;
  final IconData icon;

  const _BadgeStyle({
    required this.gradient,
    required this.iconColor,
    required this.icon,
  });
}

const _badgeStyles = {
  "gold": _BadgeStyle(
    gradient: [Color(0xFFFFE9A8), Color(0xFFD4AF37)],
    iconColor: Color(0xFF8A6A00),
    icon: LucideIcons.crown,
  ),
  "silver": _BadgeStyle(
    gradient: [Color(0xFFEDEDED), Color(0xFFB8B8B8)],
    iconColor: Color(0xFF5A5A5A),
    icon: LucideIcons.crown,
  ),
  "bronze": _BadgeStyle(
    gradient: [Color(0xFFE7B98A), Color(0xFFAD6F3B)],
    iconColor: Color(0xFF5C3A19),
    icon: LucideIcons.crown,
  ),
};

class _LeaderboardRow extends StatelessWidget {
  final SellerRank seller;
  final bool isMe;

  const _LeaderboardRow({required this.seller, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final badgeStyle = _badgeStyles[seller.badge];

    return CustomAppContainer(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      color: isMe
          ? AppColor.primaryColor.withOpacity(0.22)
          : Colors.white.withOpacity(0.12),
      borderColor: isMe
          ? AppColor.primaryColor
          : Colors.white.withOpacity(0.15),
      child: Row(
        children: [
          // ── Rank indicator (plain number, or crown for badge holders) ──
          badgeStyle != null
              ? Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: badgeStyle.gradient,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: badgeStyle.gradient.last.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    badgeStyle.icon,
                    color: badgeStyle.iconColor,
                    size: 18.sp,
                  ),
                )
              : Container(
                  width: 36.r,
                  height: 36.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  child: Text(
                    "${seller.rank}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

          SizedBox(width: 12.w),

          // ── Avatar ──
          CircleAvatar(
            radius: 18.r,
            backgroundColor: Colors.white.withOpacity(0.15),
            backgroundImage: seller.image != null
                ? NetworkImage(Global.getImageUrl(seller.image))
                : const NetworkImage("https://i.pravatar.cc/300"),
          ),

          SizedBox(width: 12.w),

          // ── Name + orders ──
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
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
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
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 11.sp,
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
