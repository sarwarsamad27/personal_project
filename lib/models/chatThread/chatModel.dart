class ChatMessage {
  final String? id;
  final String? threadId;
  final String? fromType;
  final String? fromId;
  final String? text;
  final String? timestamp;
  final String? deliveredAt;
  final String? readAt;
  final bool isExchangeRequest;
  final bool isRefundRequest; // ✅
  final ExchangeRequestData? exchangeData;
  final RefundRequestData? refundData; // ✅
  final ProductCard? productCard;

  ChatMessage({
    this.id,
    this.threadId,
    this.fromType,
    this.fromId,
    this.text,
    this.timestamp,
    this.deliveredAt,
    this.readAt,
    this.isExchangeRequest = false,
    this.isRefundRequest = false, // ✅
    this.exchangeData,
    this.refundData, // ✅
    this.productCard,
  });

  static String? _extractThreadId(Map<String, dynamic> json) {
    final direct =
        json["threadId"] ??
        json["chatThreadId"] ??
        json["thread_id"] ??
        json["threadID"];
    if (direct != null) return direct.toString();
    final thread = json["thread"];
    if (thread is String) return thread;
    if (thread is Map) {
      final tid = thread["_id"] ?? thread["id"] ?? thread["threadId"];
      if (tid != null) return tid.toString();
    }
    return null;
  }

  static String? _extractTimestamp(Map<String, dynamic> json) {
    return (json["timestamp"] ??
            json["createdAt"] ??
            json["time"] ??
            json["date"])
        ?.toString();
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: (json["_id"] ?? json["id"] ?? json["messageId"])?.toString(),
      threadId: _extractThreadId(json),
      fromType: (json["fromType"] ?? json["senderType"] ?? json["from"])
          ?.toString(),
      fromId: (json["fromId"] ?? json["senderId"])?.toString(),
      text: (json["text"] ?? json["message"])?.toString(),
      timestamp: _extractTimestamp(json),
      deliveredAt: json["deliveredAt"]?.toString(),
      readAt: json["readAt"]?.toString(),
      isExchangeRequest:
          (json["isExchangeRequest"] ?? json["type"] == "exchange") == true,
      isRefundRequest:
          (json["isRefundRequest"] ?? json["type"] == "refund") == true,
      exchangeData: json["exchangeData"] != null && json["exchangeData"] is Map
          ? ExchangeRequestData.fromJson(
              (json["exchangeData"] as Map).cast<String, dynamic>(),
            )
          : null,
      refundData: json["refundData"] != null && json["refundData"] is Map
          ? RefundRequestData.fromJson(
              (json["refundData"] as Map).cast<String, dynamic>(),
            )
          : null,
      productCard: json["productCard"] != null && json["productCard"] is Map
          ? ProductCard.fromJson(
              (json["productCard"] as Map).cast<String, dynamic>(),
            )
          : null,
    );
  }
}

class RefundRequestData {
  final String? refundId;
  final String? orderId;
  final String? productId;
  final String? productName;
  final String? reason;
  final String? reasonCategory;
  final String? status;
  final String? createdAt;
  final List<String> images;
  final String? companyNote;
  final String? pdfPath;
  final int? quantity;
  final List<String> selectedColor;
  final List<String> selectedSize;
  final double? refundAmount;

  RefundRequestData({
    this.refundId,
    this.orderId,
    this.productId,
    this.productName,
    this.reason,
    this.reasonCategory,
    this.status,
    this.createdAt,
    this.images = const [],
    this.companyNote,
    this.pdfPath,
    this.quantity,
    this.selectedColor = const [],
    this.selectedSize = const [],
    this.refundAmount,
  });

  String get reasonCategoryLabel {
    switch (reasonCategory) {
      case "seller_fault":
        return "Wrong Item";
      case "defective":
        return "Defective";
      case "size_issue":
        return "Size Issue";
      case "wrong_item":
        return "Different Product";
      case "buyer_preference":
        return "Changed Mind";
      default:
        return reasonCategory ?? "N/A";
    }
  }

  factory RefundRequestData.fromJson(Map<String, dynamic> json) {
    return RefundRequestData(
      refundId:
          (json["refundId"] ?? json["exchangeId"] ?? json["_id"] ?? json["id"])
              ?.toString(),
      orderId: (json["orderId"] ?? json["order_id"])?.toString(),
      productId: (json["productId"] ?? json["product_id"])?.toString(),
      productName: (json["productName"] ?? json["product_name"])?.toString(),
      reason: (json["reason"] ?? json["note"])?.toString(),
      reasonCategory: json["reasonCategory"]?.toString(),
      status: json["status"]?.toString(),
      createdAt: (json["createdAt"] ?? json["timestamp"])?.toString(),
      images:
          (json["images"] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      companyNote: json["companyNote"]?.toString(),
      pdfPath: json["pdfPath"]?.toString(),
      quantity: json["quantity"] is int
          ? json["quantity"]
          : int.tryParse(json["quantity"]?.toString() ?? ""),
      selectedColor:
          (json["selectedColor"] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      selectedSize:
          (json["selectedSize"] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      refundAmount: json["refundAmount"] is num
          ? (json["refundAmount"] as num).toDouble()
          : double.tryParse(json["refundAmount"]?.toString() ?? ""),
    );
  }
}

class ExchangeRequestData {
  final String? exchangeId;
  final String? orderId;
  final String? productId;
  final String? productName;
  final String? reason;
  final String? reasonCategory;
  final String? status;
  final String? createdAt;
  final List<String> images;
  final String? courierPaidBy;
  final String? resolutionType;
  final String? companyNote;
  final String? pdfPath;
  final int? quantity;
  final List<String> selectedColor;
  final List<String> selectedSize;
  final String? requestedColor;
  final String? requestedSize;

  ExchangeRequestData({
    this.exchangeId,
    this.orderId,
    this.productId,
    this.productName,
    this.reason,
    this.reasonCategory,
    this.status,
    this.createdAt,
    this.images = const [],
    this.courierPaidBy,
    this.resolutionType,
    this.companyNote,
    this.pdfPath,
    this.quantity,
    this.selectedColor = const [],
    this.selectedSize = const [],
    this.requestedColor,
    this.requestedSize,
  });

  String get reasonCategoryLabel {
    switch (reasonCategory) {
      case "seller_fault":
        return "Wrong Item";
      case "defective":
        return "Defective";
      case "size_issue":
        return "Size Issue";
      case "wrong_item":
        return "Different Product";
      case "buyer_preference":
        return "Changed Mind";
      default:
        return reasonCategory ?? "N/A";
    }
  }

  static String _normalizeStatus(String? s) {
    final v = (s ?? "pending").toLowerCase();
    if (v == "denied" || v == "reject") return "rejected";
    if (v == "approved") return "accepted";
    return v;
  }

  factory ExchangeRequestData.fromJson(Map<String, dynamic> json) {
    return ExchangeRequestData(
      exchangeId:
          (json["exchangeId"] ??
                  json["exchangeRequestId"] ??
                  json["_id"] ??
                  json["id"])
              ?.toString(),
      orderId: (json["orderId"] ?? json["order_id"])?.toString(),
      productId: (json["productId"] ?? json["product_id"])?.toString(),
      productName: (json["productName"] ?? json["product_name"])?.toString(),
      reason: (json["reason"] ?? json["note"])?.toString(),
      reasonCategory: json["reasonCategory"]?.toString(),
      status: _normalizeStatus((json["status"])?.toString()),
      createdAt: (json["createdAt"] ?? json["timestamp"])?.toString(),
      images:
          (json["images"] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      courierPaidBy: json["courierPaidBy"]?.toString(),
      resolutionType: json["resolutionType"]?.toString(),
      companyNote: json["companyNote"]?.toString(),
      pdfPath: json["pdfPath"]?.toString(),
      quantity: json["quantity"] is int
          ? json["quantity"]
          : int.tryParse(json["quantity"]?.toString() ?? ""),
      selectedColor:
          (json["selectedColor"] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      selectedSize:
          (json["selectedSize"] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      requestedColor: json["requestedColor"]?.toString(),
      requestedSize: json["requestedSize"]?.toString(),
    );
  }
}

class ProductCard {
  final String? productId;
  final String? productName;
  final String? productImage;
  final String? productPrice;
  final String? productDescription;
  final String? brandName;
  final String? sellerId;

  ProductCard({
    this.productId,
    this.productName,
    this.productImage,
    this.productPrice,
    this.productDescription,
    this.brandName,
    this.sellerId,
  });

  factory ProductCard.fromJson(Map<String, dynamic> json) {
    return ProductCard(
      productId: json["productId"]?.toString(),
      productName: json["productName"]?.toString(),
      productImage: json["productImage"]?.toString(),
      productPrice: json["productPrice"]?.toString(),
      productDescription: json["productDescription"]?.toString(),
      brandName: json["brandName"]?.toString(),
      sellerId: json["sellerId"]?.toString(),
    );
  }
}
