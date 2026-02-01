import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/view/companySide/dashboard/ChatListScreen/emptyState.dart';
import 'package:new_brand/view/companySide/dashboard/ChatListScreen/exchangeRequestpoll.dart';
import 'package:new_brand/view/companySide/dashboard/ChatListScreen/messageBubble.dart';
import 'package:provider/provider.dart';

import '../../../../viewModel/providers/chatProvider/chat_provider.dart';


class CompanyChatList extends StatelessWidget {
  const CompanyChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CompanyChatProvider>(
      builder: (_, p, __) {
        if (p.isLoadingHistory) {
          return const Center(child: CircularProgressIndicator());
        }

        if (p.messages.isEmpty) {
          return const EmptyState();
        }

        return ListView.builder(
          controller: p.scrollController,
          reverse: true,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          itemCount: p.messages.length,
          itemBuilder: (context, index) {
            final message = p.messages[index];
            if (message.isExchangeRequest == true) {
              return ExchangeRequestPoll(message: message);
            }
            return MessageBubble(message: message);
          },
        );
      },
    );
  }
}
