// models/chatModel/exchangeRequestModel.dart

class ExchangeRequestModel {
  final String? message;
  final ExchangeRequest? exchangeRequest;

  ExchangeRequestModel({this.message, this.exchangeRequest});

  factory ExchangeRequestModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRequestModel(
      message: json["message"],
      exchangeRequest: json["exchangeRequest"] != null
          ? ExchangeRequest.fromJson(json["exchangeRequest"])
          : null,
    );
  }
}

class ExchangeRequestListModel {
  final String? message;
  final List<ExchangeRequest> requests;

  ExchangeRequestListModel({this.message, this.requests = const []});

  factory ExchangeRequestListModel.fromJson(Map<String, dynamic> json) {
    final list = (json["requests"] as List?) ?? [];
    return ExchangeRequestListModel(
      message: json["message"],
      requests: list.map((e) => ExchangeRequest.fromJson(e)).toList(),
    );
  }
}

class ExchangeRequest {
  final String? id;
  final String? orderId;
  final String? productId;
  final String? buyerId;
  final String? sellerProfileId;
  final String? reason;
  final String? reasonCategory;  // seller_fault | defective | buyer_preference | size_color
  final String? resolutionType;  // replacement | refund
  final String? status;
  final String? courierPaidBy;   // seller | buyer | platform
  final List<String> images;

  // Return shipping (user → company)
  final String? returnTrackingNumber;
  final String? returnCourierName;
  final String? returnShippedAt;
  final List<String> returnProofImages;

  // Inspection
  final String? receivedAt;
  final List<String> inspectionImages;
  final String? inspectionNote;
  final String? disputeNote;
  final String? inspectedAt;

  // Resolution
  final String? replacementTrackingNumber;
  final String? replacementCourierName;
  final String? replacementShippedAt;
  final double? refundAmount;
  final String? refundedAt;

  // PDF
  final String? pdfPath;
  final String? companyNote;

  // Timeline
  final String? deliveredAt;
  final String? expiresAt;
  final String? completedAt;
  final String? createdAt;
  final String? updatedAt;

  const ExchangeRequest({
    this.id,
    this.orderId,
    this.productId,
    this.buyerId,
    this.sellerProfileId,
    this.reason,
    this.reasonCategory,
    this.resolutionType,
    this.status,
    this.courierPaidBy,
    this.images = const [],
    this.returnTrackingNumber,
    this.returnCourierName,
    this.returnShippedAt,
    this.returnProofImages = const [],
    this.receivedAt,
    this.inspectionImages = const [],
    this.inspectionNote,
    this.disputeNote,
    this.inspectedAt,
    this.replacementTrackingNumber,
    this.replacementCourierName,
    this.replacementShippedAt,
    this.refundAmount,
    this.refundedAt,
    this.pdfPath,
    this.companyNote,
    this.deliveredAt,
    this.expiresAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ExchangeRequest.fromJson(Map<String, dynamic> json) {
    return ExchangeRequest(
      id: json["_id"]?.toString(),
      orderId: json["orderId"]?.toString(),
      productId: json["productId"]?.toString(),
      buyerId: json["buyerId"]?.toString(),
      sellerProfileId: json["sellerProfileId"]?.toString(),
      reason: json["reason"]?.toString(),
      reasonCategory: json["reasonCategory"]?.toString(),
      resolutionType: json["resolutionType"]?.toString(),
      status: json["status"]?.toString(),
      courierPaidBy: json["courierPaidBy"]?.toString(),
      images: _toStringList(json["images"]),
      returnTrackingNumber: json["returnTrackingNumber"]?.toString(),
      returnCourierName: json["returnCourierName"]?.toString(),
      returnShippedAt: json["returnShippedAt"]?.toString(),
      returnProofImages: _toStringList(json["returnProofImages"]),
      receivedAt: json["receivedAt"]?.toString(),
      inspectionImages: _toStringList(json["inspectionImages"]),
      inspectionNote: json["inspectionNote"]?.toString(),
      disputeNote: json["disputeNote"]?.toString(),
      inspectedAt: json["inspectedAt"]?.toString(),
      replacementTrackingNumber: json["replacementTrackingNumber"]?.toString(),
      replacementCourierName: json["replacementCourierName"]?.toString(),
      replacementShippedAt: json["replacementShippedAt"]?.toString(),
      refundAmount: (json["refundAmount"] as num?)?.toDouble(),
      refundedAt: json["refundedAt"]?.toString(),
      pdfPath: json["pdfPath"]?.toString(),
      companyNote: json["companyNote"]?.toString(),
      deliveredAt: json["deliveredAt"]?.toString(),
      expiresAt: json["expiresAt"]?.toString(),
      completedAt: json["completedAt"]?.toString(),
      createdAt: json["createdAt"]?.toString(),
      updatedAt: json["updatedAt"]?.toString(),
    );
  }

  static List<String> _toStringList(dynamic val) {
    if (val is List) return val.map((e) => e.toString()).toList();
    return const [];
  }

  // ── Status helpers ─────────────────────────────────────────────
  bool get isPending => status == "Pending";
  bool get isAccepted => status == "Accepted";
  bool get isDenied => status == "Denied";
  bool get isReturnShipped => status == "ReturnShipped";
  bool get isReturnReceived => status == "ReturnReceived";
  bool get isInspecting => status == "Inspecting";
  bool get isApprovedInspection => status == "ApprovedInspection";
  bool get isDisputed => status == "Disputed";
  bool get isReplacementShipped => status == "ReplacementShipped";
  bool get isRefunded => status == "Refunded";
  bool get isCompleted => status == "Completed";

  bool get isActive => !isDenied && !isCompleted;

  // ── Courier cost label ────────────────────────────────────────
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

  // ── Status display label ──────────────────────────────────────
  String get statusLabel {
    switch (status) {
      case "Pending":        return "Pending Review";
      case "Accepted":       return "Accepted — Ship Product";
      case "Denied":         return "Rejected";
      case "ReturnShipped":  return "Return Shipped";
      case "ReturnReceived": return "Package Received";
      case "Inspecting":     return "Under Inspection";
      case "ApprovedInspection": return "Inspection Passed";
      case "Disputed":       return "Disputed";
      case "ReplacementShipped": return "Replacement Shipped";
      case "Refunded":       return "Refund Processed";
      case "Completed":      return "Completed";
      default:               return status ?? "Unknown";
    }
  }
}