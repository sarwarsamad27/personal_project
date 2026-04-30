import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/socketServices.dart';

class SellerAdminMessagesScreen extends StatefulWidget {
  const SellerAdminMessagesScreen({super.key});

  @override
  State<SellerAdminMessagesScreen> createState() => _SellerAdminMessagesScreenState();
}

class _SellerAdminMessagesScreenState extends State<SellerAdminMessagesScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _listenSocket();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    setState(() => _loading = true);
    try {
      final token = await LocalStorage.getToken();
      final res = await http.get(
        Uri.parse(Global.SellerGetAdminMessages),
        headers: {
          'Authorization': 'Bearer ${token ?? ''}',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['messages'] as List? ?? []);
        setState(() => _messages
          ..clear()
          ..addAll(list.map((e) => Map<String, dynamic>.from(e))));
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('fetchMessages error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _listenSocket() {
    final socket = SocketService().socket;
    socket?.on('admin:message', (data) {
      if (!mounted) return;
      setState(() => _messages.add(Map<String, dynamic>.from(data)));
      _scrollToBottom();
    });
    socket?.on('admin:broadcast', (data) {
      if (!mounted) return;
      final d = Map<String, dynamic>.from(data);
      if (d['toType'] == 'all_sellers') {
        setState(() => _messages.add(d));
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    setState(() => _sending = true);
    try {
      final token = await LocalStorage.getToken();
      final res = await http.post(
        Uri.parse(Global.SellerContactAdmin),
        headers: {
          'Authorization': 'Bearer ${token ?? ''}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'message': text}),
      );
      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        if (data['data'] != null) {
          setState(() => _messages.add(Map<String, dynamic>.from(data['data'])));
          _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint('send error: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppColor.appimagecolor,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.asset(
                'assets/images/shookoo_image.png',
                width: 32.w,
                height: 32.w,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(LucideIcons.shieldCheck, color: Colors.white, size: 22.sp),
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SHOOKOO Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                Text('Support Team', style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? _emptyState()
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) => _bubble(_messages[i]),
                      ),
          ),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _bubble(Map<String, dynamic> msg) {
    final isAdmin = msg['fromType'] == 'admin';
    final isBroadcast = msg['toType'] == 'all_sellers';
    final text = msg['message']?.toString() ?? '';
    final time = msg['createdAt'] != null
        ? DateFormat('hh:mm a').format(DateTime.tryParse(msg['createdAt'].toString()) ?? DateTime.now())
        : '';

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        mainAxisAlignment: isAdmin ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isAdmin) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.asset(
                'assets/images/shookoo_image.png',
                width: 28.w,
                height: 28.w,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: AppColor.appimagecolor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(LucideIcons.shieldCheck, size: 14.sp, color: AppColor.appimagecolor),
                ),
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isAdmin ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                if (isBroadcast)
                  Padding(
                    padding: EdgeInsets.only(bottom: 3.h),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text('📢 Broadcast', style: TextStyle(fontSize: 10.sp, color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
                    ),
                  ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isAdmin ? Colors.white : AppColor.appimagecolor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14.r),
                      topRight: Radius.circular(14.r),
                      bottomLeft: Radius.circular(isAdmin ? 4.r : 14.r),
                      bottomRight: Radius.circular(isAdmin ? 14.r : 4.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isAdmin ? Colors.black87 : Colors.white,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(time, style: TextStyle(color: Colors.grey[400], fontSize: 10.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -3))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Message SHOOKOO Admin...",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.r), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20.r), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20.r), borderSide: BorderSide.none),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: _sending ? null : _send,
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: AppColor.appimagecolor,
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: _sending
                    ? const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Icon(LucideIcons.send, color: Colors.white, size: 18.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.asset('assets/images/shookoo_image.png', width: 70.w, height: 70.w, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(LucideIcons.shieldCheck, size: 60.sp, color: Colors.grey[300])),
            ),
            SizedBox(height: 14.h),
            Text('Chat with Admin', style: TextStyle(color: Colors.black87, fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 6.h),
            Text('Send a message to SHOOKOO support', style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
          ],
        ),
      );
}
