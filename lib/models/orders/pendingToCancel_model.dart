class CancelOrderModel {
  String? message;
  CancelledOrder? order;

  CancelOrderModel({this.message, this.order});

  CancelOrderModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    order = json['order'] != null ? CancelledOrder.fromJson(json['order']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['message'] = message;
    if (order != null) data['order'] = order!.toJson();
    return data;
  }
}

class CancelledOrder {
  String? sId;
  String? status;
  String? cancelReason;
  String? cancelledAt;

  CancelledOrder({this.sId, this.status, this.cancelReason, this.cancelledAt});

  CancelledOrder.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    status = json['status'];
    cancelReason = json['cancelReason'];
    cancelledAt = json['cancelledAt'];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'status': status,
      'cancelReason': cancelReason,
      'cancelledAt': cancelledAt,
    };
  }
}