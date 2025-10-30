import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customContainer.dart';

class UserReviewsScreen extends StatelessWidget {
  final List<Map<String, String>> reviews;

  const UserReviewsScreen({super.key, required this.reviews});

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
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
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
                              review["user"]![0],
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            review["user"]!,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Text(
                            review["date"]!,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        review["feedback"]!,
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      ),
                    ],
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
