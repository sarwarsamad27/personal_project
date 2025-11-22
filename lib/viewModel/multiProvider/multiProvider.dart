import 'package:flutter/material.dart';
import 'package:new_brand/viewModel/providers/AuthProvider/forgotPassword_provider.dart';
import 'package:new_brand/viewModel/providers/AuthProvider/login_provider.dart';
import 'package:new_brand/viewModel/providers/AuthProvider/signUp_provider.dart';
import 'package:new_brand/viewModel/providers/AuthProvider/updatePassword_provider.dart';
import 'package:new_brand/viewModel/providers/AuthProvider/verifyCode_provider.dart';
import 'package:new_brand/viewModel/providers/categoryProvider/createCategory_provider.dart';
import 'package:new_brand/viewModel/providers/categoryProvider/getcategory_provider.dart';
import 'package:new_brand/viewModel/providers/categoryProvider/updateAndDeleteCategory_provider.dart';
import 'package:new_brand/viewModel/providers/productProvider/addProduct_provider.dart';
import 'package:new_brand/viewModel/providers/productProvider/deleteProduct_provider.dart';
import 'package:new_brand/viewModel/providers/productProvider/getProductCategoryWise_provider.dart';
import 'package:new_brand/viewModel/providers/productProvider/getSingleProduct_provider.dart';
import 'package:new_brand/viewModel/providers/productProvider/updateProduct_provider.dart';
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
        ChangeNotifierProvider(create: (_) => CreateCategoryProvider()),
        ChangeNotifierProvider(create: (_) => GetCategoryProvider()),
        ChangeNotifierProvider(create: (_) => UpdateDeleteCategoryProvider()),
        ChangeNotifierProvider(create: (_) => AddProductProvider()),
        ChangeNotifierProvider(create: (_) => GetProductCategoryWiseProvider()),
        ChangeNotifierProvider(create: (_) => GetSingleProductProvider()),
        ChangeNotifierProvider(create: (_) => UpdateProductProvider()),
        ChangeNotifierProvider(create: (_) => DeleteProductProvider()),
      ],
      child: child,
    );
  }
}
