class DashboardDataModel {
  String? message;
  Data? data;

  DashboardDataModel({this.message, this.data});

  DashboardDataModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? totalProducts;
  int? lowStockProducts;
  int? outOfStockProducts;
  int? totalQuantity;
  int? totalOrders;
  int? deliveredOrders;
  int? pendingOrders;
  int? totalSales;
  int? monthlySales;
  Wallet? wallet;

  Data({
    this.totalProducts,
    this.lowStockProducts,
    this.outOfStockProducts,
    this.totalQuantity,
    this.totalOrders,
    this.deliveredOrders,
    this.pendingOrders,
    this.totalSales,
    this.monthlySales,
    this.wallet,
  });

  Data.fromJson(Map<String, dynamic> json) {
    totalProducts = json['totalProducts'];
    lowStockProducts = json['lowStockProducts'];
    outOfStockProducts = json['outOfStockProducts'];
    totalQuantity = json['totalQuantity'];
    totalOrders = json['totalOrders'];
    deliveredOrders = json['deliveredOrders'];
    pendingOrders = json['pendingOrders'];
    totalSales = json['totalSales'];
    monthlySales = json['monthlySales'];
    wallet = json['wallet'] != null
        ? Wallet.fromJson(json['wallet'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalProducts'] = totalProducts;
    data['lowStockProducts'] = lowStockProducts;
    data['outOfStockProducts'] = outOfStockProducts;
    data['totalQuantity'] = totalQuantity;
    data['totalOrders'] = totalOrders;
    data['deliveredOrders'] = deliveredOrders;
    data['pendingOrders'] = pendingOrders;
    data['totalSales'] = totalSales;
    data['monthlySales'] = monthlySales;
    if (wallet != null) {
      data['wallet'] = wallet!.toJson();
    }
    return data;
  }
}

class Wallet {
  int? totalDelivered;
  int? pendingWithdraw;
  int? completedWithdraw;
  int? currentBalance;

  Wallet({
    this.totalDelivered,
    this.pendingWithdraw,
    this.completedWithdraw,
    this.currentBalance,
  });

  Wallet.fromJson(Map<String, dynamic> json) {
    totalDelivered = json['totalDelivered'];
    pendingWithdraw = json['pendingWithdraw'];
    completedWithdraw = json['completedWithdraw'];
    currentBalance = json['currentBalance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalDelivered'] = totalDelivered;
    data['pendingWithdraw'] = pendingWithdraw;
    data['completedWithdraw'] = completedWithdraw;
    data['currentBalance'] = currentBalance;
    return data;
  }
}
