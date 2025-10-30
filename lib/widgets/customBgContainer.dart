import 'package:flutter/material.dart';

class CustomBgContainer extends StatelessWidget {
  final Widget child;
  const CustomBgContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFD2A1), Color(0xFFDF762E)],
          // colors: [
          //   Colors.black.withOpacity(0.4),
          //   Colors.black.withOpacity(0.6),
          // ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
