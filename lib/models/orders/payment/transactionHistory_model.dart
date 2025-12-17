class TransactionHistoryModel {
  List<Transactions>? transactions;

  TransactionHistoryModel({this.transactions});

  TransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    if (json['transactions'] != null) {
      transactions = <Transactions>[];
      json['transactions'].forEach((v) {
        transactions!.add(new Transactions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.transactions != null) {
      data['transactions'] = this.transactions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Transactions {
  Meta? meta;
  String? sId;
  String? userId;
  String? type;
  int? amount;
  String? method;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Transactions(
      {this.meta,
      this.sId,
      this.userId,
      this.type,
      this.amount,
      this.method,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Transactions.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? new Meta.fromJson(json['meta']) : null;
    sId = json['_id'];
    userId = json['userId'];
    type = json['type'];
    amount = json['amount'];
    method = json['method'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.meta != null) {
      data['meta'] = this.meta!.toJson();
    }
    data['_id'] = this.sId;
    data['userId'] = this.userId;
    data['type'] = this.type;
    data['amount'] = this.amount;
    data['method'] = this.method;
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Meta {
  String? name;
  String? phone;

  Meta({this.name, this.phone});

  Meta.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['phone'] = this.phone;
    return data;
  }
}
