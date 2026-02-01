import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:new_brand/resources/appColor.dart';
import '../../../../viewModel/providers/chatProvider/chat_provider.dart';
  
class CompanyMessageInput extends StatelessWidget {
  const CompanyMessageInput({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CompanyChatProvider>();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.attach_file, color: Colors.black54, size: 24.sp),
              onPressed: () {},
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(25.r),
                ),
                child: TextField(
                  controller: p.msgController,
                  onChanged: p.onTyping,
                  decoration: InputDecoration(
                    hintText: "Type a message",
                    hintStyle: TextStyle(fontSize: 14.sp, color: Colors.black38),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: p.sendMessage,
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.send, color: Colors.white, size: 20.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
