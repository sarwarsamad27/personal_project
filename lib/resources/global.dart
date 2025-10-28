class Global {
  static var BaseUrl = "https://backend-code-1-8sxy.onrender.com/api/auth";
  static var SignUp = "${BaseUrl}/userregister";
  static var Login = "${BaseUrl}/userlogin";
  static var Explore = "${BaseUrl}/comprofile/all";
  static var ProductEntry = "${BaseUrl}/productentry";
  static var EditProductEntry = "${BaseUrl}/product/:id";
  static var DeleteProductEntry = "${BaseUrl}/product/:id";

  static var ProductDetailShow = "${BaseUrl}/productentry/productdetail";
  static var CompLogin = "${BaseUrl}/comlogin";
  static var CompRegister = "${BaseUrl}/comregister";
  static var CompForm = "${BaseUrl}/comprofile";
  static var CompProfile = "${BaseUrl}/comprofile";
  static var ComProductEntry = "${BaseUrl}/productentry";
  static var ComShowProductEntry = "${BaseUrl}/productentry";
  static var ComDashboard = "${BaseUrl}/company/dashboard";
  static var ComProduct = "${BaseUrl}/productentry/productdetail";
  static var CreateComProduct = "${BaseUrl}/productentry/productdetail";
  static var AddtoCart = "${BaseUrl}/favourites";
  static var FavouriteProduct = "${BaseUrl}/favourites";
  static var SearchProduct = "${BaseUrl}/allproducts";
  static var CreateOrder = "${BaseUrl}/orders";
  static var MyOrders = "${BaseUrl}/orders";

  static var DeleteFavouriteProduct = "${BaseUrl}/favourites";

  static String? loggedInCompanyId;
  static String? loggedInCompanyEmail;
}
