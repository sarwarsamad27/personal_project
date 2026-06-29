import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/widgets/admin_messages_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;
  bool _sent = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSending = true);
    try {
      final token = await LocalStorage.getToken();
      final res = await http.post(
        Uri.parse(Global.SellerContactAdmin),
        headers: {
          'Authorization': 'Bearer ${token ?? ''}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': _messageController.text.trim(),
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
        }),
      );
      if (res.statusCode == 201) {
        if (mounted) setState(() => _sent = true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send message. Try again.')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Network error. Check your connection.'),
          ),
        );
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F0),
      body: CustomScrollView(
        slivers: [
          // ── AppBar ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200.h,
            pinned: true,
            backgroundColor: AppColor.appimagecolor,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColor.appimagecolor,
                      AppColor.appimagecolor.withOpacity(0.75),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 50.h, 24.w, 20.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            LucideIcons.headphones,
                            color: Colors.white,
                            size: 26.sp,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Contact Us',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'We\'re here to help you 24/7',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            centerTitle: true,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Section Label ───────────────────────────────────
                  Text(
                    'Get in Touch',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Choose your preferred way to reach us',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // ── WhatsApp Hero Card ──────────────────────────────
                  GestureDetector(
                    onTap: () => _launch('https://wa.me/923220270729'),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(18.r),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                        ),
                        borderRadius: BorderRadius.circular(18.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF25D366).withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Icon(
                              LucideIcons.messageCircle,
                              color: Colors.white,
                              size: 26.sp,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Chat on WhatsApp',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                      ),
                                      child: Text(
                                        'Online',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '+92 322-0270729',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            LucideIcons.arrowRight,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── Email Addresses ─────────────────────────────────
                  Row(
                    children: [
                      Icon(
                        LucideIcons.mail,
                        color: AppColor.appimagecolor,
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Email Us',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  _EmailCard(
                    icon: LucideIcons.headphones,
                    color: Colors.blue,
                    label: 'Customer Support',
                    email: 'support@shookoo.pk',
                    onTap: () => _launch('mailto:support@shookoo.pk'),
                  ),
                  SizedBox(height: 10.h),
                  _EmailCard(
                    icon: LucideIcons.info,
                    color: Colors.orange,
                    label: 'General Info',
                    email: 'info@shookoo.pk',
                    onTap: () => _launch('mailto:info@shookoo.pk'),
                  ),
                  SizedBox(height: 10.h),
                  _EmailCard(
                    icon: LucideIcons.briefcase,
                    color: Colors.purple,
                    label: 'Business Contact',
                    email: 'contact@shookoo.pk',
                    onTap: () => _launch('mailto:contact@shookoo.pk'),
                  ),
                  SizedBox(height: 10.h),
                  _EmailCard(
                    icon: LucideIcons.alertCircle,
                    color: Colors.red,
                    label: 'Complaints',
                    email: 'complaint@shookoo.pk',
                    onTap: () => _launch('mailto:complaint@shookoo.pk'),
                  ),

                  SizedBox(height: 16.h),

                  // ── Social Media ───────────────────────────────────
                  _InfoCard(
                    icon: LucideIcons.share2,
                    title: 'Follow Us',
                    children: [
                      Row(
                        children: [
                          _SocialButton(
                            label: 'Facebook',
                            color: const Color(0xFF1877F2),
                            icon: LucideIcons.facebook,
                            onTap: () =>
                                _launch('https://facebook.com/shookoo.pk'),
                          ),
                          SizedBox(width: 10.w),
                          _SocialButton(
                            label: 'Instagram',
                            color: const Color(0xFFE1306C),
                            icon: LucideIcons.instagram,
                            onTap: () =>
                                _launch('https://instagram.com/shookoo.pk'),
                          ),
                          SizedBox(width: 10.w),
                          _SocialButton(
                            label: 'TikTok',
                            color: Colors.black87,
                            icon: LucideIcons.music2,
                            onTap: () => _launch('https://tiktok.com/@shookoo'),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // ── Message Form ───────────────────────────────────
                  if (!_sent) ...[
                    Container(
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.send,
                                  color: AppColor.appimagecolor,
                                  size: 18.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Send a Message',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            _FormField(
                              controller: _nameController,
                              hint: 'Your Name',
                              icon: LucideIcons.user,
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Enter your name'
                                  : null,
                            ),
                            SizedBox(height: 12.h),
                            _FormField(
                              controller: _emailController,
                              hint: 'Your Email',
                              icon: LucideIcons.mail,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => v == null || !v.contains('@')
                                  ? 'Enter valid email'
                                  : null,
                            ),
                            SizedBox(height: 12.h),
                            _FormField(
                              controller: _messageController,
                              hint: 'Your Message...',
                              icon: LucideIcons.messageSquare,
                              maxLines: 4,
                              validator: (v) => v == null || v.length < 10
                                  ? 'Message too short'
                                  : null,
                            ),
                            SizedBox(height: 16.h),
                            SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton(
                                onPressed: _isSending ? null : _send,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.appimagecolor,
                                  disabledBackgroundColor: AppColor
                                      .appimagecolor
                                      .withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isSending
                                    ? SizedBox(
                                        width: 20.r,
                                        height: 20.r,
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Send Message',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // ── Success State ────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(28.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64.r,
                            height: 64.r,
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              LucideIcons.checkCircle2,
                              color: Colors.green,
                              size: 32.sp,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          Text(
                            'Message Sent!',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Thank you for reaching out. Our team will get back to you within 24 hours.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey.shade500,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.chat_bubble_outline,
                                size: 16,
                              ),
                              label: const Text('View Admin Replies'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.appimagecolor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const SellerAdminMessagesScreen(),
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() {
                              _sent = false;
                              _nameController.clear();
                              _emailController.clear();
                              _messageController.clear();
                            }),
                            child: Text(
                              'Send Another Message',
                              style: TextStyle(
                                color: AppColor.appimagecolor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Email Card ────────────────────────────────────────────────────────────────
class _EmailCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String email;
  final VoidCallback onTap;

  const _EmailCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.email,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: color.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: Colors.white, size: 18.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.arrowUpRight,
                  size: 14.sp,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColor.appimagecolor, size: 16.sp),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }
}

// ── Social Button ─────────────────────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 18.sp),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Form Field ────────────────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontSize: 13.sp, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
        prefixIcon: maxLines == 1
            ? Icon(icon, size: 16.sp, color: Colors.grey.shade400)
            : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: maxLines > 1 ? 14.h : 0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColor.appimagecolor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
