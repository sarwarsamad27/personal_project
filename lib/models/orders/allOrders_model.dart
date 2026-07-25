import 'getMyOrders_model.dart' show Products, BuyerDetails;

class AllOrdersModel {
  String? message;
  int? page;
  int? limit;
  int? totalOrders;
  int? totalPages;
  List<AllOrderItem>? orders;

  AllOrdersModel({
    this.message,
    this.page,
    this.limit,
    this.totalOrders,
    this.totalPages,
    this.orders,
  });

  AllOrdersModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    page = json['page'];
    limit = json['limit'];
    totalOrders = json['totalOrders'];
    totalPages = json['totalPages'];
    if (json['orders'] != null) {
      orders = (json['orders'] as List)
          .map((v) => AllOrderItem.fromJson(v))
          .toList();
    }
  }
}

class AllOrderItem {
  String? sId;
  String? orderId;
  String? buyerId;
  String? profileId;
  List<Products>? products;
  int? shipmentCharges;
  int? grandTotal;
  BuyerDetails? buyerDetails;
  String? status;
  String? createdAt;
  String? deliveredAt;
  String? returnedAt;
  String? trackNumber;
  String? slipLink;
  String? paymentMethod;
  String? paymentStatus;
  String? cancelledBy;
  String? cancelReason;
  RequestInfo? exchangeRequest;
  RequestInfo? refundRequest;

  AllOrderItem({
    this.sId,
    this.orderId,
    this.buyerId,
    this.profileId,
    this.products,
    this.shipmentCharges,
    this.grandTotal,
    this.buyerDetails,
    this.status,
    this.createdAt,
    this.deliveredAt,
    this.returnedAt,
    this.trackNumber,
    this.slipLink,
    this.paymentMethod,
    this.paymentStatus,
    this.cancelledBy,
    this.cancelReason,
    this.exchangeRequest,
    this.refundRequest,
  });

  AllOrderItem.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    orderId = json['orderId'];
    buyerId = json['buyerId'];
    profileId = json['profileId'];
    if (json['products'] != null) {
      products = (json['products'] as List)
          .map((v) => Products.fromJson(v))
          .toList();
    }
    shipmentCharges = json['shipmentCharges'];
    grandTotal = json['grandTotal'];
    buyerDetails = json['buyerDetails'] != null
        ? BuyerDetails.fromJson(json['buyerDetails'])
        : null;
    status = json['status'];
    createdAt = json['createdAt'];
    deliveredAt = json['deliveredAt'];
    returnedAt = json['returnedAt'];
    trackNumber = json['trackNumber'];
    slipLink = json['slipLink'];
    paymentMethod = json['paymentMethod'];
    paymentStatus = json['paymentStatus'];
    cancelledBy = json['cancelledBy'];
    cancelReason = json['cancelReason'];
    exchangeRequest = json['exchangeRequest'] != null
        ? RequestInfo.fromJson(json['exchangeRequest'])
        : null;
    refundRequest = json['refundRequest'] != null
        ? RequestInfo.fromJson(json['refundRequest'])
        : null;
  }

  /// Products total minus nothing hidden — grandTotal already includes
  /// shipment, so this is what the products themselves add up to (what the
  /// seller detail view shows instead of a "delivery charges" line item).
  int get productsTotal => (grandTotal ?? 0) - (shipmentCharges ?? 0);
}

/// Shared shape for both exchangeRequest and refundRequest — just enough to
/// show a status badge on the order without duplicating the full
/// exchange/refund detail flow.
class RequestInfo {
  String? sId;
  String? status;
  String? reason;
  String? resolutionType;
  int? refundAmount;
  String? createdAt;

  RequestInfo({
    this.sId,
    this.status,
    this.reason,
    this.resolutionType,
    this.refundAmount,
    this.createdAt,
  });

  RequestInfo.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    status = json['status'];
    reason = json['reason'];
    resolutionType = json['resolutionType'];
    refundAmount = json['refundAmount'];
    createdAt = json['createdAt'];
  }
}
