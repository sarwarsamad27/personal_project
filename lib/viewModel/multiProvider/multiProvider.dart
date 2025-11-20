import 'package:flutter/material.dart';
import 'package:new_brand/viewModel/providers/AuthProvider/forgotPassword_provider.dart';
import 'package:new_brand/viewModel/providers/AuthProvider/login_provider.dart';
import 'package:new_brand/viewModel/providers/AuthProvider/signUp_provider.dart';
import 'package:new_brand/viewModel/providers/AuthProvider/updatePassword_provider.dart';
import 'package:new_brand/viewModel/providers/AuthProvider/verifyCode_provider.dart';
import 'package:new_brand/viewModel/providers/profileProvider/getProfile_provider.dart';
import 'package:new_brand/viewModel/providers/profileProvider/profile_provider.dart';
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
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ProfileFetchProvider()),
        ChangeNotifierProvider(create: (_) => ForgotProvider()),
        ChangeNotifierProvider(create: (_) => VerifyCodeProvider()),
        ChangeNotifierProvider(create: (_) => UpdatePasswordProvider()),
      ],
      child: child,
    );
  }
}
