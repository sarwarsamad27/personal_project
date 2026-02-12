import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/editProfileScreen.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/widgets/allConditions.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/widgets/allProfileField.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/myWallet.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/widgets/profileUserReview.dart';
import 'package:new_brand/viewModel/providers/dashboardProvider/dashboard_provider.dart';
import 'package:new_brand/viewModel/providers/profileProvider/getProfile_provider.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // FETCH on build only one time using Future.microtask
    Future.microtask(() {
      context.read<DashboardProvider>().getDashboardDataOnce();
      Provider.of<ProfileFetchProvider>(
        context,
        listen: false,
      ).getProfileOnce();
    });

    final provider = context.watch<DashboardProvider>();
    final data = provider.dashboardData?.data;

    return Scaffold(
      body: CustomBgContainer(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 50.h,
            bottom: 10.w,
          ),
          child: Consumer<ProfileFetchProvider>(
            builder: (context, provider, child) {
              // LOADING
              if (provider.loading) {
                return const Center(
                  child: SpinKitThreeBounce(
                    color: AppColor.whiteColor,
                    size: 30.0,
                  ),
                );
              }

              // ERROR
              if (provider.error != null) {
                return Center(
                  child: Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }

              // PROFILE DATA
              final profile = provider.profileData?.profile;

              if (profile == null) {
                return const Center(
                  child: Text(
                    "No profile data found",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // ------------- PROFILE IMAGE -------------
                    Stack(
                      children: [
                        Container(
                          width: 124.r,
                          height: 124.r,
                          padding: EdgeInsets.all(2.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.primaryColor,
                          ),
                          child: CircleAvatar(
                            radius: 60.r,
                            backgroundImage: profile.image != null
                                ? NetworkImage(
                                    "${Global.imageUrl}${profile.image}",
                                  )
                                : const NetworkImage(
                                    "https://i.pravatar.cc/300",
                                  ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    // ✅ PROFILE NAME
                    Text(
                      profile.name ?? "Company Name",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // ✅ PREMIUM FOLLOWERS CARD (more premium)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.18),
                            Colors.white.withOpacity(0.08),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: AppColor.primaryColor.withOpacity(0.20),
                            blurRadius: 28,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // ✨ Shine overlay (premium)
                          Positioned(
                            top: -30.h,
                            left: -40.w,
                            child: Transform.rotate(
                              angle: -0.35,
                              child: Container(
                                width: 140.w,
                                height: 90.h,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.22),
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18.r),
                                ),
                              ),
                            ),
                          ),

                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icon bubble
                              Container(
                                width: 42.r,
                                height: 42.r,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColor.primaryColor.withOpacity(0.95),
                                      AppColor.primaryColor.withOpacity(0.55),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColor.primaryColor.withOpacity(
                                        0.35,
                                      ),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  LucideIcons.users,
                                  color: Colors.white,
                                  size: 18.sp,
                                ),
                              ),

                              SizedBox(width: 12.w),

                              // Count + label
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatFollowersCount(
                                      profile.followersCount ?? 0,
                                    ),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.2,
                                      height: 1,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.25),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    children: [
                                      Text(
                                        "Followers",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.85),
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                        ),
                                      ),

                                      // tiny premium dot
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(width: 14.w),

                              // Small badge (optional premium feel)
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // ------------- EDIT PROFILE BUTTON -------------
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProfileScreen(profile: profile),
                          ),
                        );
                      },
                      child: CustomAppContainer(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        height: 40.h,
                        width: 150.w,
                        borderRadius: BorderRadius.all(Radius.circular(10.r)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Edit Profile",
                              style: TextStyle(fontSize: 15.sp),
                            ),
                            Icon(Icons.edit, color: AppColor.appimagecolor),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),
                    AllField(profile: profile),
                    SizedBox(height: 25.h),

                    // ------------- MY WALLET -------------
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WalletHistoryScreen(),
                          ),
                        );
                      },
                      child: CustomAppContainer(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 18.h,
                        ),
                        border: Border.all(color: Colors.white, width: 1),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.wallet2,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 15.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "My Wallet",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Balance: Rs. ${data?.wallet?.currentBalance ?? 0}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              LucideIcons.chevronRight,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 30.h),

                    // ---------------- REVIEWS ----------------
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "User Reviews",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    UserReview(),

                    SizedBox(height: 30.h),

                    AllCondition(),
                    SizedBox(height: 80.h),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ✅ Helper function to format followers count
  String _formatFollowersCount(int count) {
    if (count >= 1000000) {
      return "${(count / 1000000).toStringAsFixed(1)}M";
    } else if (count >= 1000) {
      return "${(count / 1000).toStringAsFixed(1)}K";
    } else {
      return count.toString();
    }
  }
}
