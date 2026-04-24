import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/resources/appColor.dart';

class TermAndConditionScreen extends StatelessWidget {
  const TermAndConditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F1),
      appBar: AppBar(
        backgroundColor: AppColor.appimagecolor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Terms & Conditions',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Banner ───────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: AppColor.appimagecolor,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.fileText, color: Colors.white, size: 32.sp),
                  SizedBox(height: 10.h),
                  Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Last updated: April 2026',
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Please read these terms carefully before using the Shookoo platform.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13.sp,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // ── Sections ────────────────────────────────────────────
            _Section(
              number: '1',
              title: 'Acceptance of Terms',
              content:
                  'By registering as a seller on Shookoo, you agree to be bound by these Terms and Conditions. If you do not agree to any part of these terms, you may not use our platform. These terms apply to all sellers, vendors, and partners who access or use the Shookoo marketplace.',
            ),

            _Section(
              number: '2',
              title: 'Seller Eligibility',
              content:
                  'To register as a seller on Shookoo, you must:\n\n• Be at least 18 years of age\n• Have a valid CNIC (Computerized National Identity Card)\n• Have a valid Pakistani mobile number\n• Have a valid bank account or mobile wallet (JazzCash/EasyPaisa)\n• Provide accurate and truthful information during registration',
            ),

            _Section(
              number: '3',
              title: 'Product Listings',
              content:
                  'As a seller, you are responsible for:\n\n• Ensuring all product descriptions are accurate and not misleading\n• Providing clear and high-quality product images\n• Setting fair and reasonable prices\n• Maintaining accurate stock/inventory levels\n• Not listing prohibited, illegal, or counterfeit products\n\nShookoo reserves the right to remove any listing that violates our policies without prior notice.',
            ),

            _Section(
              number: '4',
              title: 'Order Fulfillment',
              content:
                  'Sellers must:\n\n• Process and dispatch orders within 24-48 hours of confirmation\n• Package products securely to prevent damage during transit\n• Provide accurate tracking information where applicable\n• Maintain a minimum order fulfillment rate of 90%\n\nFailure to fulfill orders consistently may result in account suspension or termination.',
            ),

            _Section(
              number: '5',
              title: 'Payments & Commission',
              content:
                  'Shookoo operates on a commission-based model:\n\n• Commission rates are communicated at the time of onboarding\n• Payments are processed after successful order delivery\n• Funds are credited to your Shookoo wallet within 2-5 business days after delivery confirmation\n• Minimum withdrawal amount: Rs. 500\n• Withdrawals are processed within 1-3 business days\n• Shookoo reserves the right to withhold payments in case of disputes or policy violations',
            ),

            _Section(
              number: '6',
              title: 'Returns, Refunds & Exchanges',
              content:
                  'Sellers must honor Shookoo\'s return and exchange policy:\n\n• Customers may request returns/exchanges within 7 days of delivery\n• Valid reasons include: defective product, wrong item delivered, or significant mismatch from description\n• Sellers are responsible for the cost of return shipping in case of seller error\n• Refunds are processed after the returned product is inspected\n• Repeated return complaints may affect your seller rating',
            ),

            _Section(
              number: '7',
              title: 'Prohibited Items',
              content:
                  'The following items are strictly prohibited on Shookoo:\n\n• Counterfeit or pirated goods\n• Weapons, ammunition, or explosives\n• Drugs, narcotics, or controlled substances\n• Alcohol or tobacco products\n• Items that violate intellectual property rights\n• Adult or explicit content\n• Any item prohibited by Pakistani law\n\nViolation will result in immediate account termination and may be reported to relevant authorities.',
            ),

            _Section(
              number: '8',
              title: 'Seller Account & Security',
              content:
                  'You are responsible for:\n\n• Maintaining the confidentiality of your account credentials\n• All activities that occur under your account\n• Notifying Shookoo immediately of any unauthorized access\n\nShookoo will never ask for your password. Do not share your OTP or account credentials with anyone.',
            ),

            _Section(
              number: '9',
              title: 'Intellectual Property',
              content:
                  'By uploading content to Shookoo (including images, descriptions, and branding), you grant Shookoo a non-exclusive, royalty-free license to use, display, and promote this content on our platform and marketing materials. You confirm that you own or have the right to use all content you upload.',
            ),

            _Section(
              number: '10',
              title: 'Account Suspension & Termination',
              content:
                  'Shookoo reserves the right to suspend or terminate your seller account if:\n\n• You violate any of these terms\n• You engage in fraudulent activity\n• Your seller performance falls below acceptable standards\n• You receive excessive customer complaints\n• Any information provided during registration is found to be false\n\nUpon termination, any pending wallet balance will be settled after resolving outstanding disputes, typically within 30 days.',
            ),

            _Section(
              number: '11',
              title: 'Dispute Resolution',
              content:
                  'In case of disputes between sellers and buyers:\n\n• Shookoo will act as a neutral mediator\n• Both parties must provide evidence to support their claim\n• Shookoo\'s decision in disputes is final\n• Disputes must be raised within 7 days of the transaction\n\nFor seller-to-platform disputes, contact our support team at support@shookoo.pk',
            ),

            _Section(
              number: '12',
              title: 'Privacy Policy',
              content:
                  'By using Shookoo, you consent to the collection and use of your information as described in our Privacy Policy. Your personal and business data will be used solely for platform operations and will not be sold to third parties. We may share data with courier partners, payment gateways, and regulatory authorities as required by law.',
            ),

            _Section(
              number: '13',
              title: 'Limitation of Liability',
              content:
                  'Shookoo shall not be liable for:\n\n• Loss of business or profits due to platform downtime\n• Damage caused by courier services beyond our control\n• Third-party payment gateway failures\n• Force majeure events including natural disasters or government actions\n\nOur maximum liability to any seller shall not exceed the total commissions earned in the preceding 30 days.',
            ),

            _Section(
              number: '14',
              title: 'Amendments',
              content:
                  'Shookoo reserves the right to modify these Terms and Conditions at any time. Sellers will be notified of significant changes via the app or email. Continued use of the platform after changes constitutes acceptance of the revised terms.',
            ),

            _Section(
              number: '15',
              title: 'Governing Law',
              content:
                  'These Terms and Conditions are governed by the laws of Pakistan. Any disputes shall be subject to the exclusive jurisdiction of the courts of Karachi, Pakistan.',
            ),

            SizedBox(height: 20.h),

            // ── Contact Footer ───────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact & Support',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _ContactRow(
                    icon: LucideIcons.mail,
                    text: 'support@shookoo.pk',
                  ),
                  SizedBox(height: 6.h),
                  _ContactRow(icon: LucideIcons.phone, text: '+92 322-0270729'),
                  SizedBox(height: 6.h),
                  _ContactRow(icon: LucideIcons.globe, text: 'www.shookoo.pk'),
                ],
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}

// ── Section Widget ─────────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String number;
  final String title;
  final String content;

  const _Section({
    required this.number,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number badge
          Container(
            width: 28.r,
            height: 28.r,
            decoration: BoxDecoration(
              color: AppColor.appimagecolor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Contact Row ────────────────────────────────────────────────────────────────
class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColor.appimagecolor),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}
