import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BlinkingBadge extends StatefulWidget {
  final String text;
  final bool isError;

  const BlinkingBadge({Key? key, required this.text, this.isError = false})
    : super(key: key);

  @override
  _BlinkingBadgeState createState() => _BlinkingBadgeState();
}

class _BlinkingBadgeState extends State<BlinkingBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isError
        ? const Color(0xFFFEE2E2)
        : const Color(0xFFFFFBEB);
    final borderColor = widget.isError
        ? const Color(0xFFFCA5A5)
        : const Color(0xFFFCD34D);
    final dotColor = widget.isError
        ? const Color(0xFFEF4444)
        : const Color(0xFFF59E0B);
    final textColor = widget.isError
        ? const Color(0xFFB91C1C)
        : const Color(0xFF92400E);

    return FadeTransition(
      opacity: _animation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.92),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: dotColor.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: dotColor.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              widget.text,
              style: TextStyle(
                color: textColor,
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
