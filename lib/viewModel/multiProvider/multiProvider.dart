import 'package:flutter/material.dart';
import 'package:new_brand/viewModel/AuthProvider/login_provider.dart';
import 'package:new_brand/viewModel/AuthProvider/signUp_provider.dart';
import 'package:provider/provider.dart';

class AppMultiProvider extends StatelessWidget {
  final Widget child;
  const AppMultiProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignUpProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
      ],
      child: child,
    );
  }
}
