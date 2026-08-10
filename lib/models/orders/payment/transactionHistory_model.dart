class TransactionHistoryModel {
  List<Transactions>? transactions;

  TransactionHistoryModel({this.transactions});

  TransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    if (json['transactions'] != null) {
      transactions = <Transactions>[];
      json['transactions'].forEach((v) {
        transactions!.add(Transactions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (transactions != null) {
      data['transactions'] = transactions!.map((v) => v.toJson()).toList();
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
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    data['_id'] = sId;
    data['userId'] = userId;
    data['type'] = type;
    data['amount'] = amount;
    data['method'] = method;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class Meta {
  String? name;
  String? phone;
  String? bankName;
  String? accountNumber;
  String? iban;

  Meta({
    this.name,
    this.phone,
    this.bankName,
    this.accountNumber,
    this.iban,
  });

  Meta.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    phone = json['phone'];
    bankName = json['bankName'];
    accountNumber = json['accountNumber'];
    iban = json['iban'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['phone'] = phone;
    data['bankName'] = bankName;
    data['accountNumber'] = accountNumber;
    data['iban'] = iban;
    return data;
  }
}
