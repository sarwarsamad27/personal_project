import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/viewModel/providers/aiAssistantProvider/AiAssistant_provider.dart';
import 'package:provider/provider.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    FocusScope.of(context).unfocus();

    final token = await LocalStorage.getToken();
    if (!mounted) return;

    await context.read<AiAssistantProvider>().sendMessage(
      token: token ?? '',
      text: text,
    );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AiAssistantProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Row(
          children: [
            Container(
              height: 36.w,
              width: 36.w,
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, color: Colors.white, size: 18.sp),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI Assistant",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  "Ask anything about your store",
                  style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              children: [
                _introBubble(),
                SizedBox(height: 14.h),
                for (final msg in provider.messages) ...[
                  _bubble(msg),
                  SizedBox(height: 14.h),
                ],
                if (provider.isSending) _typingBubble(),
              ],
            ),
          ),
          _buildInputBar(provider.isSending),
        ],
      ),
    );
  }

  Widget _aiAvatar() {
    return Container(
      height: 30.w,
      width: 30.w,
      decoration: BoxDecoration(
        color: AppColor.primaryColor.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.auto_awesome,
        color: AppColor.primaryColor,
        size: 16.sp,
      ),
    );
  }

  Widget _introBubble() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _aiAvatar(),
        SizedBox(width: 10.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14.r),
                topRight: Radius.circular(14.r),
                bottomRight: Radius.circular(14.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              "Hi! I'm your store assistant. Ask me anything about managing "
              "your products, orders, wallet, refunds or growing your sales "
              "- I'm here to help.",
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.5,
                color: AppColor.textPrimaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bubble(AiChatMessage msg) {
    if (msg.role == AiChatRole.user) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(maxWidth: 0.78.sw),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColor.primaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14.r),
              topRight: Radius.circular(14.r),
              bottomLeft: Radius.circular(14.r),
            ),
          ),
          child: Text(
            msg.text,
            style: TextStyle(color: Colors.white, fontSize: 13.sp),
          ),
        ),
      );
    }

    final isWarning = msg.policyViolation || msg.isError;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _aiAvatar(),
        SizedBox(width: 10.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: isWarning
                  ? AppColor.errorColor.withOpacity(0.08)
                  : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14.r),
                topRight: Radius.circular(14.r),
                bottomRight: Radius.circular(14.r),
              ),
              boxShadow: isWarning
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: _formattedText(
              msg.text,
              TextStyle(
                fontSize: 13.sp,
                height: 1.5,
                color: isWarning
                    ? AppColor.errorColor
                    : AppColor.textPrimaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _formattedText(String text, TextStyle baseStyle) {
    final lines = text.split('\n');
    final widgets = <Widget>[];
    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        widgets.add(SizedBox(height: 6.h));
        continue;
      }
      if (line == '---' || line == '***' || line == '___') {
        widgets.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Divider(
              height: 1,
              color: baseStyle.color?.withOpacity(0.15),
            ),
          ),
        );
        continue;
      }

      String content = line;
      var style = baseStyle;
      final headingMatch = RegExp(r'^#{1,6}\s+(.*)$').firstMatch(line);
      if (headingMatch != null) {
        content = headingMatch.group(1)!;
        style = baseStyle.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: (baseStyle.fontSize ?? 13) + 1,
        );
      }

      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: Text.rich(
            TextSpan(children: _parseInlineSpans(content, style)),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  List<TextSpan> _parseInlineSpans(String text, TextStyle baseStyle) {
    final spans = <TextSpan>[];
    final boldPattern = RegExp(r'\*\*(.+?)\*\*');
    int start = 0;
    for (final match in boldPattern.allMatches(text)) {
      if (match.start > start) {
        spans.add(
          TextSpan(text: text.substring(start, match.start), style: baseStyle),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: baseStyle.copyWith(fontWeight: FontWeight.bold),
        ),
      );
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: baseStyle));
    }
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: baseStyle));
    }
    return spans;
  }

  Widget _typingBubble() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _aiAvatar(),
        SizedBox(width: 10.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14.r),
              topRight: Radius.circular(14.r),
              bottomRight: Radius.circular(14.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 14.w,
                height: 14.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColor.primaryColor,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                "Thinking...",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColor.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar(bool isSending) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    enabled: !isSending,
                    minLines: 1,

                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    style: TextStyle(fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: "Ask me anything about your store...",
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13.sp,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: isSending ? null : _send,
                  child: CircleAvatar(
                    radius: 22.r,
                    backgroundColor: isSending
                        ? Colors.grey[300]
                        : AppColor.primaryColor,
                    child: isSending
                        ? SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
