import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/view/companySide/auth/loginScreen.dart';
import 'package:new_brand/widgets/customBgContainer.dart';

class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

const List<_OnboardingPageData> _pages = [
  _OnboardingPageData(
    icon: Icons.storefront_rounded,
    title: "Set Up Your Store",
    description:
        "Create your seller profile and list your products in just a few minutes.",
  ),
  _OnboardingPageData(
    icon: Icons.receipt_long_rounded,
    title: "Manage Orders Easily",
    description:
        "Track, process and fulfill every order from one simple dashboard.",
  ),
  _OnboardingPageData(
    icon: Icons.trending_up_rounded,
    title: "Grow Your Business",
    description:
        "Get insights, payments and support to help your business grow with Shookoo.",
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  Future<void> _finishOnboarding() async {
    await LocalStorage.saveOnboardingSeen();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _onNext() {
    if (_currentIndex == _pages.length - 1) {
      _finishOnboarding();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentIndex == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColor.appimagecolor,
      body: CustomBgContainer(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  child: TextButton(
                    onPressed: isLastPage ? null : _finishOnboarding,
                    child: Text(
                      isLastPage ? "" : "Skip",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 160.h,
                            width: 160.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              page.icon,
                              size: 72.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 40.h),
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white.withOpacity(0.85),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: WormEffect(
                  dotHeight: 8.h,
                  dotWidth: 8.w,
                  activeDotColor: Colors.white,
                  dotColor: Colors.white.withOpacity(0.4),
                ),
              ),
              SizedBox(height: 30.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _onNext,
                    child: Text(
                      isLastPage ? "Get Started" : "Next",
                      style: TextStyle(
                        color: AppColor.primaryColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
