// view/companySide/chat/company_chat_list_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/socketServices.dart';
import 'package:new_brand/view/companySide/dashboard/ChatListScreen/chat_screen.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/widgets/admin_messages_screen.dart';
import 'package:new_brand/viewModel/providers/chatProvider/chatThread_provider.dart';
import 'package:provider/provider.dart';

class CompanyChatListScreen extends StatefulWidget {
  const CompanyChatListScreen({super.key});

  @override
  State<CompanyChatListScreen> createState() => _CompanyChatListScreenState();
}

class _CompanyChatListScreenState extends State<CompanyChatListScreen> {
  // ── Admin message state ───────────────────────────────────────────────────
  int _adminUnread = 0;
  String _adminLastMsg = 'Support & announcements';
  DateTime? _adminLastTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSocketListeners();
      _fetchAdminMessageState();
    });
  }

  // Fetch admin messages to populate last-message + count unreads
  Future<void> _fetchAdminMessageState() async {
    try {
      final token = await LocalStorage.getToken();
      final res = await http.get(
        Uri.parse(Global.SellerGetAdminMessages),
        headers: {'Authorization': 'Bearer ${token ?? ''}'},
      );
      if (res.statusCode == 200 && mounted) {
        final msgs = (jsonDecode(res.body)['messages'] as List? ?? []);
        // Messages FROM admin (replies + broadcasts to all sellers)
        final fromAdmin = msgs.where((m) => m['fromType'] == 'admin').toList();
        if (fromAdmin.isNotEmpty) {
          final last = fromAdmin.last;
          setState(() {
            _adminLastMsg  = last['message']?.toString() ?? 'Support & announcements';
            _adminLastTime = DateTime.tryParse(last['createdAt']?.toString() ?? '');
            _adminUnread   = fromAdmin.length; // simple: all admin messages = unread until opened
          });
        }
      }
    } catch (_) {}
  }

  void _setupSocketListeners() {
    final socket = SocketService().socket;
    if (socket == null || !socket.connected) return;

    socket.off("chat:message");
    socket.off("exchange:new");
    socket.off("admin:message");
    socket.off("admin:broadcast");

    socket.on("chat:message", (_) {
      if (mounted) context.read<CompanyChatThreadsProvider>().fetchThreads();
    });

    socket.on("exchange:new", (_) {
      if (mounted) context.read<CompanyChatThreadsProvider>().fetchThreads();
    });

    // Admin message / announcement received in real-time
    socket.on("admin:message", (data) {
      if (!mounted) return;
      final msg = (data is Map) ? data : {};
      setState(() {
        _adminUnread++;
        _adminLastMsg  = msg['message']?.toString() ?? _adminLastMsg;
        _adminLastTime = DateTime.now();
      });
    });

    socket.on("admin:broadcast", (data) {
      if (!mounted) return;
      final msg = (data is Map) ? data : {};
      // Only highlight if targeted at sellers
      if (msg['toType'] == 'all_sellers') {
        setState(() {
          _adminUnread++;
          _adminLastMsg  = msg['message']?.toString() ?? _adminLastMsg;
          _adminLastTime = DateTime.now();
        });
      }
    });
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return "";
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return "Just now";
      } else if (difference.inHours < 1) {
        return "${difference.inMinutes}m";
      } else if (difference.inDays == 0) {
        return DateFormat('HH:mm').format(date);
      } else if (difference.inDays == 1) {
        return "Yesterday";
      } else if (difference.inDays < 7) {
        return DateFormat('EEE').format(date);
      } else {
        return DateFormat('dd/MM').format(date);
      }
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompanyChatThreadsProvider>();
    final threads = provider.threadListModel?.threads ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Messages",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            if (threads.isNotEmpty)
              Text(
                "${threads.length} conversation${threads.length > 1 ? 's' : ''}",
                style: TextStyle(fontSize: 12.sp, color: Colors.white70),
              ),
          ],
        ),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.fetchThreads(),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                // +1 for pinned admin tile at index 0
                itemCount: threads.length + 1,
                separatorBuilder: (_, __) =>
                    Divider(height: 1.h, indent: 80.w, color: Colors.black12),
                itemBuilder: (context, i) {
                  if (i == 0) return _buildAdminTile(context);
                  final thread = threads[i - 1];
                  return _buildChatTile(thread);
                },
              ),
            ),
    );
  }

  Widget _buildAdminTile(BuildContext context) {
    final hasUnread = _adminUnread > 0;
    final timeStr   = _adminLastTime != null ? _formatTime(_adminLastTime.toString()) : '';

    return InkWell(
      onTap: () {
        // Reset unread before navigating
        setState(() => _adminUnread = 0);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SellerAdminMessagesScreen()),
        );
      },
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        leading: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(28.r),
              child: Image.asset(
                'assets/images/shookoo_image.png',
                width: 56.r,
                height: 56.r,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => CircleAvatar(
                  radius: 28.r,
                  backgroundColor: AppColor.primaryColor.withValues(alpha: 0.15),
                  child: Icon(Icons.shield_outlined, color: AppColor.primaryColor, size: 26.sp),
                ),
              ),
            ),
            if (hasUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'SHOOKOO',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            if (timeStr.isNotEmpty)
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: hasUnread ? AppColor.primaryColor : Colors.black45,
                  fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                _adminLastMsg,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: hasUnread ? Colors.black87 : Colors.black54,
                  fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasUnread)
              Container(
                margin: EdgeInsets.only(left: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '$_adminUnread',
                  style: TextStyle(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile(thread) {
    final hasUnread = thread.unreadCount > 0;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: AppColor.primaryColor.withValues(alpha: 0.1),
            backgroundImage: thread.image != null
                ? NetworkImage(thread.image!)
                : null,
            child: thread.image == null
                ? Icon(Icons.person, size: 28.sp, color: AppColor.primaryColor)
                : null,
          ),
          if (hasUnread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 14.w,
                height: 14.w,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              thread.title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatTime(thread.lastMessageTime),
            style: TextStyle(
              fontSize: 12.sp,
              color: hasUnread ? AppColor.primaryColor : Colors.black45,
              fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          if (thread.isExchangeRequest) ...[
            Icon(Icons.swap_horiz, size: 14.sp, color: AppColor.primaryColor),
            SizedBox(width: 4.w),
          ],
          Expanded(
            child: Text(
              thread.lastMessage,
              style: TextStyle(
                fontSize: 13.sp,
                color: hasUnread ? Colors.black87 : Colors.black54,
                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (hasUnread)
            Container(
              margin: EdgeInsets.only(left: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                "${thread.unreadCount}",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CompanyChatScreen(
              threadId: thread.threadId,
              toType: thread.toType,
              toId: thread.toId,
              title: thread.title,
              buyerImage: thread.image,
            ),
          ),
        ).then((_) {
          if (mounted) context.read<CompanyChatThreadsProvider>().fetchThreads();
        });
      },
    );
  }
}
