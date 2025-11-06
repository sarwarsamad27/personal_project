import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/widgets/userReviews.dart';
import 'package:new_brand/widgets/customContainer.dart';

class UserReview extends StatelessWidget {
   UserReview({super.key});
  final List<Map<String, String>> reviews = [
    {
      "user": "Alice",
      "feedback": "Great service, very responsive!",
      "date": "2025-10-25",
    },
    {
      "user": "Bob",
      "feedback": "Product quality is amazing.",
      "date": "2025-10-24",
    },
    {
      "user": "Charlie",
      "feedback": "Fast delivery, highly recommended!",
      "date": "2025-10-22",
    },
    {
      "user": "Charlie",
      "feedback": "Fast delivery, highly recommended!",
      "date": "2025-10-22",
    },
    {
      "user": "Charlie",
      "feedback": "Fast delivery, highly recommended!",
      "date": "2025-10-22",
    },
    {
      "user": "Charlie",
      "feedback": "Fast delivery, highly recommended!",
      "date": "2025-10-22",
    },
    {
      "user": "Charlie",
      "feedback": "Fast delivery, highly recommended!",
      "date": "2025-10-22",
    },
    {
      "user": "Charlie",
      "feedback": "Fast delivery, highly recommended!",
      "date": "2025-10-22",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserReviewsScreen(reviews: reviews),
                        ),
                      );
                    },
                    child: CustomAppContainer(
                      padding: EdgeInsets.symmetric(
                        vertical: 15.h,
                        horizontal: 20.w,
                      ),

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