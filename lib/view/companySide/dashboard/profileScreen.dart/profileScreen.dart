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
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/widgets/userReview.dart';
import 'package:new_brand/viewModel/providers/profileProvider/getProfile_provider.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:provider/provider.dart';

// import '../../../../models/profile/getSingleProfile_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // FETCH on build only one time using Future.microtask
    Future.microtask(() {
      Provider.of<ProfileFetchProvider>(
        context,
        listen: false,
      ).getProfileOnce();
    });

    return Scaffold(
      body: CustomBgContainer(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
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

                      SizedBox(height: 20.h),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditProfileScreen(profile: profile),
                            ),
                          );
                        },
                        child: CustomAppContainer(
                          padding: EdgeInsets.symmetric(horizontal: 10),
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
                          height: 40.h,
                          width: 150,
                          borderRadius: BorderRadius.all(Radius.circular(10.r)),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      AllField(profile: profile),
                      SizedBox(height: 25.h),

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
                                      "Balance: Rs. 12,450",
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
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
