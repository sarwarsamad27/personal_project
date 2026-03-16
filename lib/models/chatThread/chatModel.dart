// models/chatThread/chatModel.dart

import 'package:new_brand/models/productModel/productCard_model.dart';

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
  final ExchangeRequestData? exchangeData;
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
    this.exchangeData,
    this.productCard,
  });

  static String? _extractThreadId(Map<String, dynamic> json) {
    final direct = json["threadId"] ??
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
      fromType:
          (json["fromType"] ?? json["senderType"] ?? json["from"])?.toString(),
      fromId: (json["fromId"] ?? json["senderId"])?.toString(),
      text: (json["text"] ?? json["message"])?.toString(),
      timestamp: _extractTimestamp(json),
      deliveredAt: json["deliveredAt"]?.toString(),
      readAt: json["readAt"]?.toString(),
      isExchangeRequest:
          (json["isExchangeRequest"] ?? json["type"] == "exchange") == true,
      exchangeData: json["exchangeData"] != null && json["exchangeData"] is Map
          ? ExchangeRequestData.fromJson(
              (json["exchangeData"] as Map).cast<String, dynamic>(),
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

class ExchangeRequestData {
  final String? exchangeId;
  final String? orderId;
  final String? productId;
  final String? productName;
  final String? reason;
  final String? reasonCategory; // ✅ NEW: seller_fault | defective | buyer_preference | size_color
  final String? status;
  final String? createdAt;
  final String? courierPaidBy;  // ✅ NEW: seller | buyer | platform
  final String? resolutionType; // ✅ NEW: replacement | refund
  final String? companyNote;    // ✅ NEW: seller ka note
  final String? pdfPath;        // ✅ NEW: generated PDF path
  final List<String> images;

  ExchangeRequestData({
    this.exchangeId,
    this.orderId,
    this.productId,
    this.productName,
    this.reason,
    this.reasonCategory,
    this.status,
    this.createdAt,
    this.courierPaidBy,
    this.resolutionType,
    this.companyNote,
    this.pdfPath,
    this.images = const [],
  });

  static String _normalizeStatus(String? s) {
    final v = (s ?? "pending").toLowerCase();
    if (v == "denied") return "rejected";
    if (v == "reject") return "rejected";
    if (v == "approved") return "accepted";
    return v;
  }

  /// ✅ Human readable reason category label
  String get reasonCategoryLabel {
    switch (reasonCategory) {
      case "seller_fault":
        return "Wrong Item Received";
      case "defective":
        return "Defective / Damaged";
      case "size_color":
        return "Wrong Size / Color";
      case "buyer_preference":
        return "Changed My Mind";
      default:
        return reasonCategory ?? "N/A";
    }
  }

  /// ✅ Courier cost label
  String get courierCostLabel {
    switch (courierPaidBy) {
      case "seller":
        return "Courier cost: Seller's responsibility";
      case "buyer":
        return "Return courier cost: Your responsibility";
      case "platform":
        return "Courier cost: Platform will handle";
      default:
        return "";
    }
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
      reasonCategory: json["reasonCategory"]?.toString(), // ✅
      status: _normalizeStatus((json["status"])?.toString()),
      createdAt: (json["createdAt"] ?? json["timestamp"])?.toString(),
      courierPaidBy: json["courierPaidBy"]?.toString(),   // ✅
      resolutionType: json["resolutionType"]?.toString(), // ✅
      companyNote: json["companyNote"]?.toString(),       // ✅
      pdfPath: json["pdfPath"]?.toString(),               // ✅
      images: (json["images"] as List?)?.map((e) => e.toString()).toList() ??
          const [],
    );
  }
}