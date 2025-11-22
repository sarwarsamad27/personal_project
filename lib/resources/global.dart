// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps

class Global {
  static var BaseUrl = "http://10.0.2.2:5000/api/auth";
  static var SignUp = "${BaseUrl}/signup";
  static var Login = "${BaseUrl}/login";
  static var CreateProfile = "${BaseUrl}/create/profile";
  static var GetProfile = "${BaseUrl}/profile";
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
}
