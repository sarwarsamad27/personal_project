// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps

class Global {
  // static var BaseUrl = "http://10.0.2.2:5000/api/auth";
  // static var imageUrl = "http://10.0.2.2:5000";
  static var imageUrl = "http://192.168.100.49:5000";
  static var BaseUrl = "http://192.168.100.49:5000/api/auth";

  static var SignUp = "${BaseUrl}/signup";
  static var Login = "${BaseUrl}/login";
  static var GoogleLogin = "${BaseUrl}/google/login";
  static var AppleLogin = "${BaseUrl}/apple/login";
  static var CreateProfile = "${BaseUrl}/create/profile";
  static var GetProfile = "${BaseUrl}/profile";
  static var UpdateProfile = "${BaseUrl}/update/profile";
  static var ForgotPassword = "${BaseUrl}/forgot-password";
  static var VerifyCode = "${BaseUrl}/verifycode";
  static var UpdatePassword = "${BaseUrl}/reset/password";
  static var CreateCategory = "${BaseUrl}/create/category";
  static var GetCategory = "${BaseUrl}/category";
  static var EditCategory = "${BaseUrl}/edit/category";
  static var DeleteCategory = "${BaseUrl}/delete/category";
  static var CreateProduct = "${BaseUrl}/create/product";
  static var GetProduct = "${BaseUrl}/get/products";
  static var GetSingleProduct = "${BaseUrl}/get/single/product";
  static var UpdateSingleProduct = "${BaseUrl}/update/product";
  static var DeleteSingleProduct = "${BaseUrl}/delete/product";
  static var GetOrders = "${BaseUrl}/get/orders";
  static var PendingToDispatched = "${BaseUrl}/pending/to/dispatched/orders";
  static var GetDispatchedOrder = "${BaseUrl}/get/dispatched/orders";
  static var GetReturnedOrder = "${BaseUrl}/get/returned/orders";
  static var GetDeliveredOrder = "${BaseUrl}/get/delivered/orders";
  static var GetCompanyAmount = "${BaseUrl}/get/company/wallet";
  static var PaymentRequest = "${BaseUrl}/withdraw/send/code";
  static var PaymentVerifycode = "${BaseUrl}/withdraw/verify";
  static var TransactionHistory = "${BaseUrl}/transactions";
  static var GetDashboardData = "${BaseUrl}/get/dashboard/data";
  static var GetCompanySalesChart = "${BaseUrl}/get/sales/chart";
  static var GetCompanyReviews = "${BaseUrl}/get/reviews";
  static var ReplyReviews = "${BaseUrl}/reply/reviews";
  static var GetRelatedProduct = "${BaseUrl}/get/related/products";
  static var saveFcmToken = "${BaseUrl}/seller/save/fcm-token";
  static var getExchangeRequest = "${BaseUrl}/get/exchange/requests";
  static var exchangeDecision = "${BaseUrl}/exchange";
  static var companyChatThreads = "$BaseUrl/company/chat/threads";
  static var companyChatMessages = "$BaseUrl/company/chat/messages";
}
