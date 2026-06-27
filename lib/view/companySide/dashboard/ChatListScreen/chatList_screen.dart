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
import 'package:new_brand/view/companySide/dashboard/aiAssistant/aiAssistantScreen.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/widgets/admin_messages_screen.dart';
import 'package:new_brand/viewModel/providers/chatProvider/chatThread_provider.dart';
import 'package:new_brand/viewModel/providers/profileProvider/getProfile_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
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

  // Guard: only fetch admin state once on first open
  bool _adminFetched = false;

  // Guard: only register socket listeners once per screen lifetime — they
  // stay bound the whole time this screen is mounted (even while a chat
  // thread is pushed on top of it), since each handler is now unbound by
  // reference in dispose(), not via a blanket socket.off(event) that would
  // wipe it out from elsewhere.
  bool _socketListenersBound = false;
  final List<void Function()> _socketUnsubscribers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch threads only once — never on re-entry
      final p = context.read<CompanyChatThreadsProvider>();
      if (p.threadListModel == null) {
        p.fetchThreads();
      }

      // Fetch admin state only once
      if (!_adminFetched) {
        _adminFetched = true;
        _fetchAdminMessageState();
      }

      _setupSocketListeners();
    });
  }

  @override
  void dispose() {
    for (final unsubscribe in _socketUnsubscribers) {
      unsubscribe();
    }
    _socketUnsubscribers.clear();
    super.dispose();
  }

  // ── Admin messages: one-time HTTP fetch ──────────────────────────────────
  Future<void> _fetchAdminMessageState() async {
    try {
      final token = await LocalStorage.getToken();
      final res = await http.get(
        Uri.parse(Global.SellerGetAdminMessages),
        headers: {'Authorization': 'Bearer ${token ?? ''}'},
      );
      if (res.statusCode == 200 && mounted) {
        final msgs = (jsonDecode(res.body)['messages'] as List? ?? []);
        if (msgs.isNotEmpty) {
          final last = msgs.last;
          final profile = context.read<ProfileFetchProvider>().profileData?.profile;
          final userId = profile?.userId;

          final fromAdmin = msgs.where((m) => m['fromType'] == 'admin').toList();
          final unreadCount = fromAdmin.where((m) {
            if (m['toType'] == 'seller') return m['isRead'] == false;
            if (m['toType'] == 'all_sellers') {
              final readBy = (m['readBy'] as List? ?? []);
              return userId != null && !readBy.contains(userId);
            }
            return false;
          }).length;

          if (mounted) {
            setState(() {
              _adminLastMsg = last['message']?.toString() ?? 'Support & announcements';
              _adminLastTime = DateTime.tryParse(last['createdAt']?.toString() ?? '');
              _adminUnread = unreadCount;
            });
          }
        }
      }
    } catch (_) {}
  }

  // ── Socket listeners ─────────────────────────────────────────────────────
  // Registered once and left bound for this screen's whole lifetime — each
  // handler is unbound by reference in dispose() (via the unsubscribe
  // callback socket.on() returns), so opening a chat thread or the admin
  // screen on top no longer needs to wipe and re-register these.
  void _setupSocketListeners() async {
    if (_socketListenersBound) return;

    final token = await LocalStorage.getToken() ?? "";
    if (token.isEmpty || !mounted) return;

    // ensureConnected waits if not yet connected — no early exit
    final socket = await SocketService().ensureConnected(
      baseUrl: Global.imageUrl,
      token: token,
    );
    if (socket == null || !mounted || _socketListenersBound) return;
    _socketListenersBound = true;

    // ── New buyer message: update thread list in-memory, no API call ─────
    _socketUnsubscribers.add(socket.on("chat:message", (data) {
      if (!mounted || data is! Map) return;
      final tId = data["threadId"]?.toString();
      final text = (data["text"] ?? "").toString();
      final imageUrl = data["imageUrl"]?.toString();
      final displayText = text.isNotEmpty ? text : (imageUrl != null ? "📷 Image" : "");
      final ts = (data["timestamp"] ?? data["createdAt"] ?? DateTime.now().toIso8601String()).toString();
      final fromType = data["fromType"]?.toString();

      if (tId != null) {
        context.read<CompanyChatThreadsProvider>().onNewMessage(
          threadId: tId,
          lastMessage: displayText,
          lastMessageTime: ts,
          incrementUnread: fromType != "seller",
          isExchangeRequest: false,
        );
      }
    }));

    // ── New exchange request: same in-memory update ───────────────────────
    _socketUnsubscribers.add(socket.on("exchange:new", (data) {
      if (!mounted || data is! Map) return;
      final tId = data["threadId"]?.toString();
      final ts = DateTime.now().toIso8601String();
      if (tId != null) {
        context.read<CompanyChatThreadsProvider>().onNewMessage(
          threadId: tId,
          lastMessage: "📦 New exchange request",
          lastMessageTime: ts,
          incrementUnread: true,
          isExchangeRequest: true,
        );
      }
    }));

    // ── Admin messages: update local state ───────────────────────────────
    _socketUnsubscribers.add(socket.on("admin:message", (data) {
      if (!mounted) return;
      final msg = (data is Map) ? data : {};
      if (msg['fromType'] == 'admin') {
        setState(() {
          _adminUnread++;
          _adminLastMsg = msg['message']?.toString() ?? _adminLastMsg;
          _adminLastTime = DateTime.now();
        });
      }
    }));

    _socketUnsubscribers.add(socket.on("admin:broadcast", (data) {
      if (!mounted) return;
      final msg = (data is Map) ? data : {};
      if (msg['toType'] == 'all_sellers') {
        setState(() {
          _adminUnread++;
          _adminLastMsg = msg['message']?.toString() ?? _adminLastMsg;
          _adminLastTime = DateTime.now();
        });
      }
    }));
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return "";
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inMinutes < 1) return "Just now";
      if (difference.inHours < 1) return "${difference.inMinutes}m";
      if (difference.inDays == 0) return DateFormat('HH:mm').format(date);
      if (difference.inDays == 1) return "Yesterday";
      if (difference.inDays < 7) return DateFormat('EEE').format(date);
      return DateFormat('dd/MM').format(date);
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompanyChatThreadsProvider>();
    final threads = provider.threads;

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
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
            ),
            if (threads.isNotEmpty)
              Text(
                "${threads.length} conversation${threads.length > 1 ? 's' : ''}",
                style: TextStyle(fontSize: 12.sp, color: Colors.white70),
              ),
          ],
        ),
      ),
      body: provider.loading && threads.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: AppColor.primaryColor,
              onRefresh: () => provider.fetchThreads(),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: threads.length + 2, // +2 for pinned AI + admin tiles
                separatorBuilder: (_, __) =>
                    Divider(height: 1.h, indent: 80.w, color: Colors.black12),
                itemBuilder: (context, i) {
                  if (i == 0) return _buildAiAssistantTile(context);
                  if (i == 1) return _buildAdminTile(context);
                  final thread = threads[i - 2];
                  return _buildChatTile(thread, provider);
                },
              ),
            ),
    );
  }

  Widget _buildAiAssistantTile(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
        );
      },
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        leading: CircleAvatar(
          radius: 28.r,
          backgroundColor: AppColor.primaryColor.withValues(alpha: 0.15),
          child: Icon(LucideIcons.bot, color: AppColor.primaryColor, size: 26.sp),
        ),
        title: Text(
          'AI Assistant',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          'Ask me anything about your store',
          style: TextStyle(fontSize: 13.sp, color: Colors.black54),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildAdminTile(BuildContext context) {
    final hasUnread = _adminUnread > 0;
    final timeStr = _adminLastTime != null ? _formatTime(_adminLastTime.toString()) : '';

    return InkWell(
      onTap: () {
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

  Widget _buildChatTile(thread, CompanyChatThreadsProvider provider) {
    final hasUnread = thread.unreadCount > 0;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: AppColor.primaryColor.withValues(alpha: 0.1),
            backgroundImage: thread.image != null ? NetworkImage(thread.image!) : null,
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
                style: TextStyle(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      onTap: () {
        // Mark thread as read immediately — no API call
        provider.markThreadRead(thread.threadId);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CompanyChatScreen(
              threadId: thread.threadId,
              toType: thread.toType,
              toId: thread.toId,
              title: thread.title,
              buyerImage: thread.image,
              onThreadUpdate: ({
                required lastMessage,
                required timestamp,
                required isSellerMsg,
              }) {
                if (!mounted) return;
                context.read<CompanyChatThreadsProvider>().onNewMessage(
                  threadId: thread.threadId,
                  lastMessage: lastMessage,
                  lastMessageTime: timestamp,
                  // Seller's own messages don't add to unread count
                  incrementUnread: !isSellerMsg,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
