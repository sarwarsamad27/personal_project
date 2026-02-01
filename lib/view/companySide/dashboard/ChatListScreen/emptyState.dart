import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../viewModel/providers/chatProvider/chat_provider.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final title = context.read<CompanyChatProvider>().title;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80.sp, color: Colors.black26),
          SizedBox(height: 16.h),
          Text(
            "No messages yet",
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Start a conversation with $title",
            style: TextStyle(fontSize: 13.sp, color: Colors.black38),
          ),
        ],
      ),
    );
  }
}
