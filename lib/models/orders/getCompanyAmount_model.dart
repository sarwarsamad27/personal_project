class GetCompanyAmountModel {
  String? message;
  double? totalDelivered;
  double? totalWithdrawn;
  double? totalDeposited;
  double? pendingBalance;
  double? currentBalance;

  GetCompanyAmountModel({
    this.message,
    this.totalDelivered,
    this.totalWithdrawn,
    this.totalDeposited,
    this.pendingBalance,
    this.currentBalance,
  });

  factory GetCompanyAmountModel.fromJson(Map<String, dynamic> json) {
    return GetCompanyAmountModel(
      message:        json['message'],
      totalDelivered: (json['totalDelivered'] as num?)?.toDouble() ?? 0.0,
      totalWithdrawn: (json['totalWithdrawn'] as num?)?.toDouble() ?? 0.0,
      totalDeposited: (json['totalDeposited'] as num?)?.toDouble() ?? 0.0,
      pendingBalance: (json['pendingBalance'] as num?)?.toDouble() ?? 0.0,
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}