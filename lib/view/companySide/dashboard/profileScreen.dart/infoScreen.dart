import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';

class InfoScreen extends StatelessWidget {
  final String title;
  final String content;

  const InfoScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColor.primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white),
            ),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
