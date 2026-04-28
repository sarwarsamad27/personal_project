// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps

class Global {
  //   static var BaseUrl = "https://seller-and-buyer-backend.onrender.com/api/auth";
  //   static var imageUrl = "https://seller-and-buyer-backend.onrender.com";
  // static var imageUrl = "http://192.168.30.124:5000";
  // static var BaseUrl = "http://192.168.30.124:5000/api/auth";
  static var BaseUrl = "http://10.0.2.2:5000/api/auth";
  static var imageUrl = "http://10.0.2.2:5000";
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
  static var PendingToCancelled = "${BaseUrl}/pending/to/cancelled/orders";
  static var GetDispatchedOrder = "${BaseUrl}/get/dispatched/orders";
  static var GetReturnedOrder = "${BaseUrl}/get/returned/orders";
  static var GetDeliveredOrder = "${BaseUrl}/get/delivered/orders";
  static var GetCompanyAmount = "${BaseUrl}/get/company/wallet";
  static var PaymentRequest = "${BaseUrl}/withdraw/send/code";
  static var PaymentVerifycode = "${BaseUrl}/withdraw/verify";
  static var AddMoneyInitiate = "${BaseUrl}/add-money/jazzcash/initiate";
  static var AddMoneyConfirm = "${BaseUrl}/add-money/jazzcash/confirm";
  static var TransactionHistory = "${BaseUrl}/transactions";
  static var GetDashboardData = "${BaseUrl}/get/dashboard/data";
  static var GetCompanySalesChart = "${BaseUrl}/get/sales/chart";
  static var GetCompanyReviews = "${BaseUrl}/get/reviews";
  static var ReplyReviews = "${BaseUrl}/reply/reviews";
  static var GetRelatedProduct = "${BaseUrl}/get/related/products";
  static var saveFcmToken = "${BaseUrl}/seller/save/fcm-token";
  static var getExchangeRequest = "${BaseUrl}/get/exchange/requests";
  // static var exchangeDecision = "${BaseUrl}/exchange";
  static var companyChatThreads = "$BaseUrl/company/chat/threads";
  static var companyChatMessages = "$BaseUrl/company/chat/messages";
  static var generateInvoicePdf = "${BaseUrl}/generate/invoice/pdf";
  static var analyzeProductImage = "${BaseUrl}/analyze-product-image";
  static var AcceptOrder = "${BaseUrl}/accept/order";
  // static var createExchangeRequest =
  //     "${BaseUrl}/api/buyer/create/exchange/request";
  // static var getExchangeRequests = "${BaseUrl}/api/buyer/get/exchange/requests";
  // static var getExchangePdf = "${BaseUrl}/api/buyer/get/exchange";
  static var getCompanyRefundRequests = "${BaseUrl}/get/refund/requests";
  static String refundMarkReceived(String id) =>
      "${BaseUrl}/refund/$id/mark-received";
  static String refundStartInspection(String id) =>
      "${BaseUrl}/refund/$id/start-inspection";
  static String refundInspectionResult(String id) =>
      "${BaseUrl}/refund/$id/inspection-result";
  static String refundFinalize(String id) => "${BaseUrl}/refund/$id/finalize";
  // Company side
  // static var getCompanyExchangeRequests =
  //     "${BaseUrl}/api/get/exchange/requests";
  // static var exchangeDecision = "${BaseUrl}/api/exchange"; // /:id/decision

  // Base for dynamic routes (/:id/mark-received, etc.)
  // static var exchangeBase = "${BaseUrl}/api/exchange";
  // User return proof: POST /buyer/exchange/:id/return-proof
  // static var buyerExchangeBase = "${BaseUrl}/api/buyer/exchange";

  static var getCompanyExchangeRequests = "${BaseUrl}/get/exchange/requests";
  // static var exchangeDecision = "${BaseUrl}/exchange";
  static var exchangeBase = "${BaseUrl}/exchange";

  /// GET  /get/exchange/requests?status=Pending  (list all)
  // static var getCompanyExchangeRequests = "${BaseUrl}/get/exchange/requests";

  /// PUT  /exchange/:id/decision
  /// Body: { decision: "Accepted"|"Denied", resolutionType: "replacement"|"refund", note? }
  static String exchangeDecision(String exchangeId) =>
      "${BaseUrl}/exchange/$exchangeId/decision";
  static var leopardsCities = "${BaseUrl}/leopards/cities";

  /// PUT  /exchange/:id/mark-received
  /// Body: { inspectionImages?: base64[] }
  static String markReturnReceived(String exchangeId) =>
      "${BaseUrl}/exchange/$exchangeId/mark-received";

  /// PUT  /exchange/:id/start-inspection
  static String startInspection(String exchangeId) =>
      "${BaseUrl}/exchange/$exchangeId/start-inspection";

  /// PUT  /exchange/:id/inspection-result
  /// Body: { result: "approved"|"disputed", inspectionNote: string }
  static String submitInspectionResult(String exchangeId) =>
      "${BaseUrl}/exchange/$exchangeId/inspection-result";

  /// PUT  /exchange/:id/ship-replacement
  /// Body: { trackingNumber, courierName }
  static String shipReplacement(String exchangeId) =>
      "${BaseUrl}/exchange/$exchangeId/ship-replacement";

  /// PUT  /exchange/:id/process-refund
  /// Body: { refundAmount }
  static String processRefund(String exchangeId) =>
      "${BaseUrl}/exchange/$exchangeId/process-refund";

  /// PUT  /exchange/:id/complete
  static String markCompleted(String exchangeId) =>
      "${BaseUrl}/exchange/$exchangeId/complete";

  // ── Refund (Company) ───────────────────────────────────────────
  static String refundDecision(String refundId) =>
      "${BaseUrl}/refund/$refundId/decision";

  static String updateRefundStatus(String refundId) =>
      "${BaseUrl}/refund/$refundId/status";

  static String leopardsTrack(String trackNumber) =>
      "${BaseUrl}/leopards/track/$trackNumber";

  static String leopardsRequestPickup = "${BaseUrl}/leopards/request-pickup";

  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return ''; // ya koi default image
    }

    // Agar already full URL hai (cloudinary)
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // Agar local upload hai (/uploads/...)
    if (imagePath.startsWith('/uploads/')) {
      return imageUrl + imagePath; // imageUrl = "https://yourapi.com"
    }

    // Normal case
    return imageUrl + imagePath;
  }
}
