class DashboardDataModel {
  String? message;
  Data? data;

  DashboardDataModel({this.message, this.data});

  DashboardDataModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? totalProducts;
  int? totalQuantity;
  int? totalOrders;
  int? deliveredOrders;
  int? pendingOrders;
  int? totalSales;
  int? monthlySales;
  Wallet? wallet;

  Data(
      {this.totalProducts,
      this.totalQuantity,
      this.totalOrders,
      this.deliveredOrders,
      this.pendingOrders,
      this.totalSales,
      this.monthlySales,
      this.wallet});

  Data.fromJson(Map<String, dynamic> json) {
    totalProducts = json['totalProducts'];
    totalQuantity = json['totalQuantity'];
    totalOrders = json['totalOrders'];
    deliveredOrders = json['deliveredOrders'];
    pendingOrders = json['pendingOrders'];
    totalSales = json['totalSales'];
    monthlySales = json['monthlySales'];
    wallet =
        json['wallet'] != null ? new Wallet.fromJson(json['wallet']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalProducts'] = this.totalProducts;
    data['totalQuantity'] = this.totalQuantity;
    data['totalOrders'] = this.totalOrders;
    data['deliveredOrders'] = this.deliveredOrders;
    data['pendingOrders'] = this.pendingOrders;
    data['totalSales'] = this.totalSales;
    data['monthlySales'] = this.monthlySales;
    if (this.wallet != null) {
      data['wallet'] = this.wallet!.toJson();
    }
    return data;
  }
}

class Wallet {
  int? totalDelivered;
  int? pendingWithdraw;
  int? completedWithdraw;
  int? currentBalance;

  Wallet(
      {this.totalDelivered,
      this.pendingWithdraw,
      this.completedWithdraw,
      this.currentBalance});

  Wallet.fromJson(Map<String, dynamic> json) {
    totalDelivered = json['totalDelivered'];
    pendingWithdraw = json['pendingWithdraw'];
    completedWithdraw = json['completedWithdraw'];
    currentBalance = json['currentBalance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalDelivered'] = this.totalDelivered;
    data['pendingWithdraw'] = this.pendingWithdraw;
    data['completedWithdraw'] = this.completedWithdraw;
    data['currentBalance'] = this.currentBalance;
    return data;
  }
}
