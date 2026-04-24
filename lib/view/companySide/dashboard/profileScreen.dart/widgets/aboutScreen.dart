import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/resources/appColor.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F0),
      body: CustomScrollView(
        slivers: [
          // ── AppBar ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220.h,
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
                      AppColor.appimagecolor.withOpacity(0.7),
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
                        // Logo circle
                        Container(
                          width: 56.r,
                          height: 56.r,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'S',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Shookoo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Pakistan\'s Multi-Vendor Marketplace',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            title: Text(
              'About Us',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
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
                  // ── Version Badge ──────────────────────────────────
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.appimagecolor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColor.appimagecolor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Version 1.0.0  •  Beta',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColor.appimagecolor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // ── Mission ────────────────────────────────────────
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CardTitle(
                          icon: LucideIcons.target,
                          title: 'Our Mission',
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Shookoo aims to empower Pakistani entrepreneurs and small businesses by providing them a digital marketplace to reach customers across the country — easily, efficiently, and affordably.',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade600,
                            height: 1.65,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // ── Vision ────────────────────────────────────────
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CardTitle(icon: LucideIcons.eye, title: 'Our Vision'),
                        SizedBox(height: 10.h),
                        Text(
                          'To become Pakistan\'s most trusted and seller-friendly ecommerce platform — where every entrepreneur, from any city or town, can build a successful online business.',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade600,
                            height: 1.65,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // ── Stats Row ──────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: '500+',
                          label: 'Target Sellers',
                          icon: LucideIcons.store,
                          color: Colors.purple,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _StatCard(
                          value: 'PKR',
                          label: 'COD Available',
                          icon: LucideIcons.banknote,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _StatCard(
                          value: '24/7',
                          label: 'Support',
                          icon: LucideIcons.headphones,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 14.h),

                  // ── What We Offer ──────────────────────────────────
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CardTitle(
                          icon: LucideIcons.sparkles,
                          title: 'What We Offer',
                        ),
                        SizedBox(height: 12.h),
                        _FeatureRow(
                          icon: LucideIcons.shoppingBag,
                          text:
                              'Multi-vendor marketplace — multiple stores, one platform',
                        ),
                        _FeatureRow(
                          icon: LucideIcons.truck,
                          text: 'COD delivery via PostEx, Leopards & TCS',
                        ),
                        _FeatureRow(
                          icon: LucideIcons.wallet,
                          text:
                              'Seller wallet with JazzCash & EasyPaisa support',
                        ),
                        _FeatureRow(
                          icon: LucideIcons.arrowLeftRight,
                          text: 'Easy exchange & refund management',
                        ),
                        _FeatureRow(
                          icon: LucideIcons.barChart2,
                          text: 'Real-time sales analytics & dashboard',
                        ),
                        _FeatureRow(
                          icon: LucideIcons.bell,
                          text: 'Push notifications for orders & payments',
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // ── Team ──────────────────────────────────────────
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CardTitle(icon: LucideIcons.users, title: 'The Team'),
                        SizedBox(height: 12.h),
                        _TeamMember(
                          name: 'Sarwar Samad',
                          role: 'Founder & Lead Developer',
                          initials: 'SS',
                          color: AppColor.appimagecolor,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // ── Tech Stack ─────────────────────────────────────
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CardTitle(
                          icon: LucideIcons.code2,
                          title: 'Built With',
                        ),
                        SizedBox(height: 12.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: [
                            _TechChip(label: 'Flutter'),
                            _TechChip(label: 'Node.js'),
                            _TechChip(label: 'MongoDB'),
                            _TechChip(label: 'Firebase'),
                            _TechChip(label: 'Twilio'),
                            _TechChip(label: 'Cloudinary'),
                            _TechChip(label: 'Socket.IO'),
                            _TechChip(label: 'PostEx API'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // ── Legal ──────────────────────────────────────────
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CardTitle(icon: LucideIcons.fileText, title: 'Legal'),
                        SizedBox(height: 10.h),
                        _LegalRow(label: 'Business Name', value: 'Shookoo.Pk'),
                        _LegalRow(label: 'Type', value: 'Sole Proprietorship'),
                        _LegalRow(label: 'City', value: 'Karachi, Pakistan'),
                        _LegalRow(label: 'Website', value: 'www.shookoo.pk'),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // ── Copyright ──────────────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '© 2026 Shookoo. All rights reserved.',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Made with ❤️ in Karachi, Pakistan',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),

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

// ── Reusable Widgets ──────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

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
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _CardTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9.sp, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(5.r),
            decoration: BoxDecoration(
              color: AppColor.appimagecolor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(icon, size: 12.sp, color: AppColor.appimagecolor),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamMember extends StatelessWidget {
  final String name, role, initials;
  final Color color;
  const _TeamMember({
    required this.name,
    required this.role,
    required this.initials,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22.r,
          backgroundColor: color.withOpacity(0.15),
          child: Text(
            initials,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 13.sp,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            Text(
              role,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
            ),
          ],
        ),
      ],
    );
  }
}

class _TechChip extends StatelessWidget {
  final String label;
  const _TechChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColor.appimagecolor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColor.appimagecolor.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          color: AppColor.appimagecolor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LegalRow extends StatelessWidget {
  final String label, value;
  const _LegalRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
