class PaymentRequestModel {
  String? message;
  String? phone;

  PaymentRequestModel({this.message, this.phone});

  PaymentRequestModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['phone'] = phone;
    return data;
  }
}
