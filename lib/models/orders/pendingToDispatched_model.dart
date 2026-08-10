class PendingToDispatchedModel {
  String? message;
  Order? order;

  PendingToDispatchedModel({this.message, this.order});

  PendingToDispatchedModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    order = json['order'] != null ? Order.fromJson(json['order']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (order != null) {
      data['order'] = order!.toJson();
    }
    return data;
  }
}

class Order {
  BuyerDetails? buyerDetails;
  String? sId;
  String? buyerId;
  String? profileId;
  List<Products>? products;
  int? shipmentCharges;
  int? grandTotal;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Order(
      {this.buyerDetails,
      this.sId,
      this.buyerId,
      this.profileId,
      this.products,
      this.shipmentCharges,
      this.grandTotal,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Order.fromJson(Map<String, dynamic> json) {
    buyerDetails = json['buyerDetails'] != null
        ? BuyerDetails.fromJson(json['buyerDetails'])
        : null;
    sId = json['_id'];
    buyerId = json['buyerId'];
    profileId = json['profileId'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
    shipmentCharges = json['shipmentCharges'];
    grandTotal = json['grandTotal'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (buyerDetails != null) {
      data['buyerDetails'] = buyerDetails!.toJson();
    }
    data['_id'] = sId;
    data['buyerId'] = buyerId;
    data['profileId'] = profileId;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    data['shipmentCharges'] = shipmentCharges;
    data['grandTotal'] = grandTotal;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class BuyerDetails {
  String? name;
  String? email;
  String? phone;
  String? address;
  String? additionalNote;

  BuyerDetails(
      {this.name, this.email, this.phone, this.address, this.additionalNote});

  BuyerDetails.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    address = json['address'];
    additionalNote = json['additionalNote'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['address'] = address;
    data['additionalNote'] = additionalNote;
    return data;
  }
}

class Products {
  String? productId;
  String? name;
  int? quantity;
  int? price;
  int? totalPrice;
  List<String>? images;
  List<String>? selectedColor;
  List<String>? selectedSize;
  String? sId;

  Products(
      {this.productId,
      this.name,
      this.quantity,
      this.price,
      this.totalPrice,
      this.images,
      this.selectedColor,
      this.selectedSize,
      this.sId});

  Products.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    name = json['name'];
    quantity = json['quantity'];
    price = json['price'];
    totalPrice = json['totalPrice'];
    images = json['images'].cast<String>();
    selectedColor = json['selectedColor'].cast<String>();
    selectedSize = json['selectedSize'].cast<String>();
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productId'] = productId;
    data['name'] = name;
    data['quantity'] = quantity;
    data['price'] = price;
    data['totalPrice'] = totalPrice;
    data['images'] = images;
    data['selectedColor'] = selectedColor;
    data['selectedSize'] = selectedSize;
    data['_id'] = sId;
    return data;
  }
}
