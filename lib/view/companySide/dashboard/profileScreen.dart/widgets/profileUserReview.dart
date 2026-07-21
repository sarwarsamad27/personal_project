import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/widgets/userReviews.dart';
import 'package:new_brand/viewModel/providers/reviewProvider/getAllReview_provider.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:provider/provider.dart';

class UserReview extends StatefulWidget {
  final String? productId;
  final String? categoryId;

  const UserReview({super.key, this.productId, this.categoryId});

  @override
  State<UserReview> createState() => _UserReviewState();
}

class _UserReviewState extends State<UserReview> {
  bool _loading = false;

  Future<void> _openReviews() async {
    if (_loading) return; // block re-tap while a fetch is already in flight

    setState(() => _loading = true);

    // Modal barrier blocks all taps elsewhere on the screen until data arrives.
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => const Center(
        child: SpinKitThreeBounce(color: AppColor.whiteColor, size: 30.0),
      ),
    );

    final provider = context.read<CompanyReviewProvider>();
    await provider.fetchReviews();

    if (!mounted) return;
    Navigator.pop(context); // close loading dialog
    setState(() => _loading = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserReviewsScreen(reviews: provider.reviews),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openReviews,
      child: CustomAppContainer(
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
        child: Row(
          children: [
            Icon(LucideIcons.star, color: Colors.white),
            SizedBox(width: 10.w),
            Text(
              "View All Reviews",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            Spacer(),
            Icon(LucideIcons.chevronRight, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
