class GetCompanyAmountModel {
  String? message;
  int? totalDelivered;
  int? totalWithdrawn;
  int? currentBalance;

  GetCompanyAmountModel(
      {this.message,
      this.totalDelivered,
      this.totalWithdrawn,
      this.currentBalance});

  GetCompanyAmountModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    totalDelivered = json['totalDelivered'];
    totalWithdrawn = json['totalWithdrawn'];
    currentBalance = json['currentBalance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['totalDelivered'] = this.totalDelivered;
    data['totalWithdrawn'] = this.totalWithdrawn;
    data['currentBalance'] = this.currentBalance;
    return data;
  }
}
