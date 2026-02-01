import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:new_brand/resources/appColor.dart';
import '../../../../viewModel/providers/chatProvider/chat_provider.dart';

class CompanyChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CompanyChatAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CompanyChatProvider>();

    return AppBar(
      backgroundColor: AppColor.primaryColor,
      elevation: 1,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: Colors.white,
            backgroundImage: p.buyerImage != null ? NetworkImage(p.buyerImage!) : null,
            child: p.buyerImage == null
                ? Icon(Icons.person, size: 20.sp, color: AppColor.primaryColor)
                : null,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (p.isTyping)
                  Text(
                    "typing...",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
