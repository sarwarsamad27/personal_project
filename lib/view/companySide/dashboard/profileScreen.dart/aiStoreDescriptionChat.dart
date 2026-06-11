import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/viewModel/providers/profileProvider/AnalyzeStoreProvider.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:provider/provider.dart';

enum _BubbleRole { ai, aiError, user }

class _ChatBubble {
  final _BubbleRole role;
  final String text;
  const _ChatBubble.ai(this.text) : role = _BubbleRole.ai;
  const _ChatBubble.error(this.text) : role = _BubbleRole.aiError;
  const _ChatBubble.user(this.text) : role = _BubbleRole.user;
}

/// AI chat bottom sheet that looks at the store's name, image and address
/// (via Claude) and writes a 4-5 line store description for the seller.
/// The seller can also type extra instructions to refine the result.
class AiStoreDescriptionChat extends StatefulWidget {
  final String name;
  final String address;
  final File? image;
  final String? imageUrl;
  final ValueChanged<String> onUseDescription;

  const AiStoreDescriptionChat({
    super.key,
    required this.name,
    required this.address,
    this.image,
    this.imageUrl,
    required this.onUseDescription,
  });

  @override
  State<AiStoreDescriptionChat> createState() =>
      _AiStoreDescriptionChatState();
}

class _AiStoreDescriptionChatState extends State<AiStoreDescriptionChat> {
  final TextEditingController _promptController = TextEditingController();
  final List<_ChatBubble> _messages = [];
  String? _latestDescription;
  ScrollController? _listController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _generate());
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = _listController;
      if (controller != null && controller.hasClients) {
        controller.animateTo(
          controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _generate({String? prompt}) async {
    if (prompt != null && prompt.isNotEmpty) {
      setState(() => _messages.add(_ChatBubble.user(prompt)));
      _scrollToBottom();
    }

    final token = await LocalStorage.getToken();
    if (!mounted) return;

    final provider = context.read<AnalyzeStoreProvider>();
    await provider.generateDescription(
      token: token ?? '',
      name: widget.name,
      address: widget.address,
      image: widget.image,
      imageUrl: widget.imageUrl,
      prompt: prompt,
      previousDescription: _latestDescription,
      onSuccess: (description) {
        if (!mounted) return;
        setState(() {
          _latestDescription = description;
          _messages.add(_ChatBubble.ai(description));
        });
        _scrollToBottom();
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _messages.add(_ChatBubble.error(error)));
        _scrollToBottom();
      },
    );
  }

  void _sendPrompt() {
    final text = _promptController.text.trim();
    _promptController.clear();
    FocusScope.of(context).unfocus();
    _generate(prompt: text.isEmpty ? null : text);
  }

  @override
  Widget build(BuildContext context) {
    final isAnalyzing = context.watch<AnalyzeStoreProvider>().isAnalyzing;

    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        _listController = scrollController;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              _buildHeader(),
              Divider(height: 1, color: Colors.grey[200]),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(16.w),
                  children: [
                    _userRequestBubble(),
                    SizedBox(height: 14.h),
                    for (final msg in _messages) ...[
                      _buildBubble(msg),
                      SizedBox(height: 14.h),
                    ],
                    if (isAnalyzing) _aiTypingBubble(),
                  ],
                ),
              ),
              _buildBottomActions(isAnalyzing),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBubble(_ChatBubble msg) {
    switch (msg.role) {
      case _BubbleRole.user:
        return _userPromptBubble(msg.text);
      case _BubbleRole.ai:
        return _aiDescriptionBubble(msg.text);
      case _BubbleRole.aiError:
        return _aiErrorBubble(msg.text);
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 12.w, 12.h),
      child: Row(
        children: [
          Container(
            height: 38.w,
            width: 38.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.primaryColor,
                  AppColor.primaryColor.withOpacity(0.7),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI Store Assistant",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textPrimaryColor,
                  ),
                ),
                Text(
                  "Writes your store description for you",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColor.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: Colors.grey[500], size: 22.sp),
          ),
        ],
      ),
    );
  }

  Widget _userRequestBubble() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.8.sw),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColor.primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14.r),
            topRight: Radius.circular(14.r),
            bottomLeft: Radius.circular(14.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Take a look at my store and write a short description for it.",
              style: TextStyle(color: Colors.white, fontSize: 13.sp),
            ),
            SizedBox(height: 8.h),
            _infoChip(Icons.storefront, widget.name),
            SizedBox(height: 4.h),
            _infoChip(Icons.location_on_outlined, widget.address),
            if (widget.image != null) ...[
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.file(
                  widget.image!,
                  height: 90.h,
                  width: 120.w,
                  fit: BoxFit.cover,
                ),
              ),
            ] else if (widget.imageUrl != null &&
                widget.imageUrl!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.network(
                  widget.imageUrl!,
                  height: 90.h,
                  width: 120.w,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _userPromptBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.8.sw),
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
          text,
          style: TextStyle(color: Colors.white, fontSize: 13.sp),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 14.sp),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            text.isEmpty ? "—" : text,
            style: TextStyle(color: Colors.white70, fontSize: 11.sp),
          ),
        ),
      ],
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

  Widget _aiTypingBubble() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _aiAvatar(),
        SizedBox(width: 10.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14.r),
              topRight: Radius.circular(14.r),
              bottomRight: Radius.circular(14.r),
            ),
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
                "Looking at your store details...",
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

  Widget _aiDescriptionBubble(String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _aiAvatar(),
        SizedBox(width: 10.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14.r),
                topRight: Radius.circular(14.r),
                bottomRight: Radius.circular(14.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Here's a description for your store:",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textSecondaryColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.5,
                    color: AppColor.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _aiErrorBubble(String error) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _aiAvatar(),
        SizedBox(width: 10.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColor.errorColor.withOpacity(0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14.r),
                topRight: Radius.circular(14.r),
                bottomRight: Radius.circular(14.r),
              ),
            ),
            child: Text(
              "Sorry, I couldn't generate a description right now.\n$error",
              style: TextStyle(fontSize: 12.sp, color: AppColor.errorColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(bool isAnalyzing) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 100.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: TextField(
                      controller: _promptController,
                      enabled: !isAnalyzing,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendPrompt(),
                      style: TextStyle(fontSize: 13.sp),
                      decoration: InputDecoration(
                        hintText: "Tell AI what to add or change...",
                        border: InputBorder.none,
                        isCollapsed: true,
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: isAnalyzing ? null : _sendPrompt,
                  child: CircleAvatar(
                    radius: 22.r,
                    backgroundColor: isAnalyzing
                        ? Colors.grey[300]
                        : AppColor.primaryColor,
                    child: isAnalyzing
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
            if (_latestDescription != null && !isAnalyzing) ...[
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "Use this description",
                  onTap: () {
                    widget.onUseDescription(_latestDescription!);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
