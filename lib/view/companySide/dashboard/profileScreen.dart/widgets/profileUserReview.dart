import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/widgets/userReviews.dart';
import 'package:new_brand/viewModel/providers/reviewProvider/getAllReview_provider.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:provider/provider.dart';

class UserReview extends StatelessWidget {
  final String? productId;
  final String? categoryId;

  const UserReview({super.key, this.productId, this.categoryId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Fetch reviews before navigating
        final provider = context.read<CompanyReviewProvider>();
        provider.fetchReviews().then((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserReviewsScreen(reviews: provider.reviews),
            ),
          );
        });
      },
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
