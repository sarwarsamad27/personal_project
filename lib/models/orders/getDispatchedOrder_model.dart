class GetDispatchedOrderModel {
  String? message;
  String? profileId;
  int? page;
  int? limit;
  int? totalOrders;
  int? totalPages;
  List<Orders>? orders;

  GetDispatchedOrderModel(
      {this.message,
      this.profileId,
      this.page,
      this.limit,
      this.totalOrders,
      this.totalPages,
      this.orders});

  GetDispatchedOrderModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    profileId = json['profileId'];
    page = json['page'];
    limit = json['limit'];
    totalOrders = json['totalOrders'];
    totalPages = json['totalPages'];
    if (json['orders'] != null) {
      orders = <Orders>[];
      json['orders'].forEach((v) {
        orders!.add(Orders.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['profileId'] = profileId;
    data['page'] = page;
    data['limit'] = limit;
    data['totalOrders'] = totalOrders;
    data['totalPages'] = totalPages;
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Orders {
  String? sId;
  String? buyerId;
  String? orderId;
  String? profileId;
  List<Products>? products;
  int? shipmentCharges;
  int? grandTotal;
  BuyerDetails? buyerDetails;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? trackNumber;
  String? slipLink;
  String? paymentMethod;
  String? paymentStatus;

  Orders({
    this.sId,
    this.buyerId,
    this.profileId,
    this.products,
    this.orderId,
    this.shipmentCharges,
    this.grandTotal,
    this.buyerDetails,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.trackNumber,
    this.slipLink,
    this.paymentMethod,
    this.paymentStatus,
  });

  Orders.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    buyerId = json['buyerId'];
    orderId = json['orderId'];
    profileId = json['profileId'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
    shipmentCharges = json['shipmentCharges'];
    grandTotal = json['grandTotal'];
    buyerDetails = json['buyerDetails'] != null
        ? BuyerDetails.fromJson(json['buyerDetails'])
        : null;
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    trackNumber = json['trackNumber'];
    slipLink = json['slipLink'];
    paymentMethod = json['paymentMethod'];
    paymentStatus = json['paymentStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['buyerId'] = buyerId;
    data['profileId'] = profileId;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    data['shipmentCharges'] = shipmentCharges;
    data['grandTotal'] = grandTotal;
    if (buyerDetails != null) {
      data['buyerDetails'] = buyerDetails!.toJson();
    }
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['trackNumber'] = trackNumber;
    data['slipLink'] = slipLink;
    data['paymentMethod'] = paymentMethod;
    data['paymentStatus'] = paymentStatus;
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
  String? categoryId;
  String? profileId;

  Products(
      {this.productId,
      this.name,
      this.quantity,
      this.price,
      this.totalPrice,
      this.images,
      this.selectedColor,
      this.selectedSize,
      this.sId,
      this.categoryId,
      this.profileId});

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
    categoryId = json['categoryId'];
    profileId = json['profileId'];
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
    data['categoryId'] = categoryId;
    data['profileId'] = profileId;
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
