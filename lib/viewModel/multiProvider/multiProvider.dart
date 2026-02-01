import 'package:flutter/material.dart';
import 'package:new_brand/viewModel/providers/AuthProvider/appleLogin_provider.dart';
import 'package:new_brand/viewModel/providers/AuthProvider/forgotPassword_provider.dart';
import 'package:new_brand/viewModel/providers/AuthProvider/googleLogin_provider.dart';
import 'package:new_brand/viewModel/providers/AuthProvider/login_provider.dart';
import 'package:new_brand/viewModel/providers/AuthProvider/signUp_provider.dart';
import 'package:new_brand/viewModel/providers/AuthProvider/updatePassword_provider.dart';
import 'package:new_brand/viewModel/providers/AuthProvider/verifyCode_provider.dart';
import 'package:new_brand/viewModel/providers/categoryProvider/createCategory_provider.dart';
import 'package:new_brand/viewModel/providers/categoryProvider/getcategory_provider.dart';
import 'package:new_brand/viewModel/providers/categoryProvider/updateAndDeleteCategory_provider.dart';
import 'package:new_brand/viewModel/providers/chatProvider/chatThread_provider.dart';
import 'package:new_brand/viewModel/providers/dashboardProvider/companySaleChart_provider.dart';
import 'package:new_brand/viewModel/providers/dashboardProvider/dashboard_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/getCompanyAmount_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/getDeliveredOrder_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/getDispatchedorder_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/getReturnedOrder_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/order_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/pendingToDispatched_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/transactionHIstory_provider.dart';
import 'package:new_brand/viewModel/providers/productProvider/addProduct_provider.dart';
import 'package:new_brand/viewModel/providers/productProvider/deleteProduct_provider.dart';
import 'package:new_brand/viewModel/providers/productProvider/getProductCategoryWise_provider.dart';
import 'package:new_brand/viewModel/providers/productProvider/getRelatedProduct_provider.dart';
import 'package:new_brand/viewModel/providers/productProvider/getSingleProduct_provider.dart';
import 'package:new_brand/viewModel/providers/productProvider/updateProduct_provider.dart';
import 'package:new_brand/viewModel/providers/profileProvider/getProfile_provider.dart';
import 'package:new_brand/viewModel/providers/profileProvider/profile_provider.dart';
import 'package:new_brand/viewModel/providers/profileProvider/updateProfile_provider.dart';
import 'package:new_brand/viewModel/providers/reviewProvider/getAllReview_provider.dart';
import 'package:new_brand/viewModel/providers/reviewProvider/replyReview_provider.dart';
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
        ChangeNotifierProvider(create: (_) => GetMyOrdersProvider()),
        ChangeNotifierProvider(create: (_) => EditProfileProvider()),
        ChangeNotifierProvider(create: (_) => GetDispatchedOrderProvider()),
        ChangeNotifierProvider(create: (_) => GetReturnedOrderProvider()),
        ChangeNotifierProvider(create: (_) => PendingToDispatchedProvider()),
        ChangeNotifierProvider(create: (_) => GetDeliveredOrderProvider()),
        ChangeNotifierProvider(create: (_) => CompanyWalletProvider()),
        ChangeNotifierProvider(create: (_) => TransactionHistoryProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => CompanySalesChartProvider()),
        ChangeNotifierProvider(create: (_) => CompanyReviewProvider()),
        ChangeNotifierProvider(create: (_) => ReplyReviewProvider()),
        ChangeNotifierProvider(create: (_) => GetRelatedProductProvider()),
        ChangeNotifierProvider(create: (_) => CompanyGoogleLoginProvider()),
        ChangeNotifierProvider(create: (_) => CompanyChatThreadsProvider()),
        ChangeNotifierProvider(create: (_) => CompanyAppleLoginProvider()),
      ],

      child: child,
    );
  }
}
