import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/productDetail/productDetailScreen.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:intl/intl.dart';
import '../../../../../models/review/getAllReview_model.dart';

class UserReviewsScreen extends StatelessWidget {
  final List<Data> reviews; // ✅ MODEL LIST

  const UserReviewsScreen({super.key, required this.reviews});

  String getEmailPrefix(String email) {
    if (email.contains("@")) {
      return email.split("@")[0];
    }
    return email;
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "";
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat("dd MMM yyyy").format(parsedDate);
      // Example: 24 Dec 2025
    } catch (e) {
      return date;
    }
  }

  /// ⭐ STAR BUILDER (100% WORKING)
  List<Widget> buildStars(int starCount) {
    return List.generate(
      5,
      (index) => Icon(
        Icons.star,
        color: index < starCount
            ? Colors
                  .amber // ⭐ filled
            : Colors.white30, // empty
        size: 18.sp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Reviews"),
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

              final int starCount = review.stars ?? 0; // ✅ DIRECT INT

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
                                Row(children: buildStars(starCount)),
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
                        Text(
                          review.text ?? "",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
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
}
