import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/resources/appColor.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  int? _expandedIndex;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Account',
    'Orders',
    'Payments',
    'Shipping',
    'Returns',
  ];

  final List<Map<String, dynamic>> _faqs = [
    // Account
    {
      'category': 'Account',
      'q': 'How do I register as a seller on Shookoo?',
      'a':
          'Download the Shookoo Seller app, tap "Sign Up", fill in your details including name, email, phone number, and CNIC. After email verification, complete your store profile and you\'re ready to start selling.',
    },
    {
      'category': 'Account',
      'q': 'Can I have multiple stores on one account?',
      'a':
          'Currently, each account is limited to one store. If you need multiple stores, you can register with different email addresses for each business.',
    },
    {
      'category': 'Account',
      'q': 'How do I reset my password?',
      'a':
          'On the login screen, tap "Forgot Password", enter your registered email address, and follow the instructions sent to your email to reset your password.',
    },
    {
      'category': 'Account',
      'q': 'How do I update my store information?',
      'a':
          'Go to Profile → Edit Profile. You can update your store name, logo, address, phone number, and description. Changes are reflected immediately.',
    },

    // Orders
    {
      'category': 'Orders',
      'q': 'How will I know when I receive a new order?',
      'a':
          'You will receive a push notification instantly when a new order is placed. You can also check the Orders section in your dashboard at any time.',
    },
    {
      'category': 'Orders',
      'q': 'How long do I have to process an order?',
      'a':
          'Orders must be dispatched within 24-48 hours of confirmation. Delays may negatively affect your seller rating and could result in order cancellation.',
    },
    {
      'category': 'Orders',
      'q': 'What should I do if I cannot fulfill an order?',
      'a':
          'If you are unable to fulfill an order, cancel it immediately through the app and notify the customer. Frequent cancellations may result in account penalties.',
    },
    {
      'category': 'Orders',
      'q': 'Can I edit an order after it has been placed?',
      'a':
          'Orders cannot be edited once confirmed. If there is an issue with the order details, contact Shookoo support immediately through the app.',
    },

    // Payments
    {
      'category': 'Payments',
      'q': 'When will I receive payment for delivered orders?',
      'a':
          'Payments are credited to your Shookoo wallet within 2-5 business days after successful delivery confirmation. You can then withdraw to your JazzCash, EasyPaisa, or bank account.',
    },
    {
      'category': 'Payments',
      'q': 'What is the minimum withdrawal amount?',
      'a':
          'The minimum withdrawal amount is Rs. 500. Withdrawals are processed within 1-3 business days after your request is approved by the admin.',
    },
    {
      'category': 'Payments',
      'q': 'What withdrawal methods are available?',
      'a':
          'You can withdraw to JazzCash, EasyPaisa, or a bank account. Make sure your payment details are correct before requesting a withdrawal.',
    },
    {
      'category': 'Payments',
      'q': 'Is there a daily withdrawal limit?',
      'a':
          'Yes, the daily withdrawal limit is Rs. 50,000. If you need to withdraw more, contact support for assistance.',
    },
    {
      'category': 'Payments',
      'q': 'What commission does Shookoo charge?',
      'a':
          'Commission rates are communicated at the time of onboarding and depend on the product category. The commission is automatically deducted before crediting earnings to your wallet.',
    },

    // Shipping
    {
      'category': 'Shipping',
      'q': 'Which courier services does Shookoo use?',
      'a':
          'Shookoo is integrated with PostEx, Leopards Courier, and TCS for nationwide delivery. COD (Cash on Delivery) is available through all courier partners.',
    },
    {
      'category': 'Shipping',
      'q': 'How are shipping charges calculated?',
      'a':
          'Shipping charges are based on package weight, dimensions, and delivery location. Charges are typically borne by the customer unless you offer free shipping.',
    },
    {
      'category': 'Shipping',
      'q': 'Can I choose which courier to use for each order?',
      'a':
          'Currently, Shookoo automatically assigns the courier based on availability and your pickup location. This feature will be customizable in future updates.',
    },
    {
      'category': 'Shipping',
      'q': 'How do I track my shipments?',
      'a':
          'Once an order is dispatched, a tracking number is generated automatically. You and the customer can track the shipment in real-time through the app.',
    },

    // Returns
    {
      'category': 'Returns',
      'q': 'What is Shookoo\'s return policy?',
      'a':
          'Customers can request returns or exchanges within 7 days of delivery for valid reasons such as defective products, wrong items, or significant mismatch from description.',
    },
    {
      'category': 'Returns',
      'q': 'Who bears the cost of return shipping?',
      'a':
          'If the return is due to seller error (wrong or defective product), the seller bears the return shipping cost. If it is a customer preference return, the customer bears the cost.',
    },
    {
      'category': 'Returns',
      'q': 'How does the exchange process work?',
      'a':
          'When a customer requests an exchange, you will receive a notification. Accept or decline the request. If accepted, the courier will pick up the old item and deliver the replacement simultaneously.',
    },
    {
      'category': 'Returns',
      'q': 'When are refunds processed?',
      'a':
          'Refunds are processed after the returned product is received and inspected. Once approved, the refund is credited to the customer\'s wallet within 2-3 business days.',
    },
  ];

  List<Map<String, dynamic>> get _filtered => _selectedCategory == 'All'
      ? _faqs
      : _faqs.where((f) => f['category'] == _selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F0),
      body: CustomScrollView(
        slivers: [
          // ── AppBar ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180.h,
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
                        Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            LucideIcons.helpCircle,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'FAQ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '${_faqs.length} frequently asked questions',
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

            centerTitle: true,
          ),

          // ── Category Filter ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedCategory = cat;
                        _expandedIndex = null;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: 8.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColor.appimagecolor
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColor.appimagecolor
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // ── Count ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
              child: Text(
                '${_filtered.length} questions in "$_selectedCategory"',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
              ),
            ),
          ),

          // ── FAQ List ────────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 40.h),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final faq = _filtered[index];
                final isOpen = _expandedIndex == index;
                final category = faq['category'] as String;

                return GestureDetector(
                  onTap: () =>
                      setState(() => _expandedIndex = isOpen ? null : index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.only(bottom: 10.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isOpen
                            ? AppColor.appimagecolor.withOpacity(0.4)
                            : Colors.transparent,
                        width: 1.2,
                      ),
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
                        // Question row
                        Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category icon
                              Container(
                                padding: EdgeInsets.all(6.r),
                                decoration: BoxDecoration(
                                  color: _categoryColor(
                                    category,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  _categoryIcon(category),
                                  size: 14.sp,
                                  color: _categoryColor(category),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Category label
                                    Text(
                                      category,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: _categoryColor(category),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      faq['q'] as String,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              AnimatedRotation(
                                turns: isOpen ? 0.5 : 0,
                                duration: const Duration(milliseconds: 250),
                                child: Icon(
                                  LucideIcons.chevronDown,
                                  size: 18.sp,
                                  color: isOpen
                                      ? AppColor.appimagecolor
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Answer
                        if (isOpen) ...[
                          Divider(
                            height: 1,
                            color: Colors.grey.shade100,
                            indent: 16.w,
                            endIndent: 16.w,
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              16.w,
                              12.h,
                              16.w,
                              16.h,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 3.w,
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    color: AppColor.appimagecolor.withOpacity(
                                      0.4,
                                    ),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    faq['a'] as String,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade600,
                                      height: 1.65,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }, childCount: _filtered.length),
            ),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Account':
        return Colors.purple;
      case 'Orders':
        return Colors.blue;
      case 'Payments':
        return Colors.green;
      case 'Shipping':
        return Colors.orange;
      case 'Returns':
        return Colors.red;
      default:
        return AppColor.appimagecolor;
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Account':
        return LucideIcons.user;
      case 'Orders':
        return LucideIcons.shoppingBag;
      case 'Payments':
        return LucideIcons.wallet;
      case 'Shipping':
        return LucideIcons.truck;
      case 'Returns':
        return LucideIcons.arrowLeftRight;
      default:
        return LucideIcons.helpCircle;
    }
  }
}
