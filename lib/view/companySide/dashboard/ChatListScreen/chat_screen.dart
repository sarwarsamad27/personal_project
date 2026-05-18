import 'package:flutter/material.dart';
import 'package:new_brand/view/companySide/dashboard/ChatListScreen/chatAppBar.dart';
import 'package:new_brand/view/companySide/dashboard/ChatListScreen/companyChatList.dart';
import 'package:new_brand/view/companySide/dashboard/ChatListScreen/messageInput.dart';
import 'package:new_brand/view/companySide/dashboard/ChatListScreen/typingIndicator.dart';
import 'package:provider/provider.dart';

import '../../../../viewModel/providers/chatProvider/chat_provider.dart';

class CompanyChatScreen extends StatelessWidget {
  final String threadId;
  final String toType;
  final String toId;
  final String title;
  final String? buyerImage;
  final void Function({
    required String lastMessage,
    required String timestamp,
    required bool isSellerMsg,
  })? onThreadUpdate;

  const CompanyChatScreen({
    super.key,
    required this.threadId,
    required this.toType,
    required this.toId,
    required this.title,
    this.buyerImage,
    this.onThreadUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompanyChatProvider(
        threadId: threadId,
        toType: toType,
        toId: toId,
        title: title,
        buyerImage: buyerImage,
        onThreadUpdate: onThreadUpdate,
      )..init(),
      child: Scaffold(
        backgroundColor: const Color(0xFFECE5DD),
        appBar: const CompanyChatAppBar(),
        body: Column(
          children: [
            const Expanded(child: CompanyChatList()),
            Consumer<CompanyChatProvider>(
              builder: (_, p, __) => p.isTyping
                  ? const TypingIndicator()
                  : const SizedBox.shrink(),
            ),
            const CompanyMessageInput(),
          ],
        ),
      ),
    );
  }
}
