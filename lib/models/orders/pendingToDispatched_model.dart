class PendingToDispatchedModel {
  String? message;
  Order? order;

  PendingToDispatchedModel({this.message, this.order});

  PendingToDispatchedModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    order = json['order'] != null ? new Order.fromJson(json['order']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.order != null) {
      data['order'] = this.order!.toJson();
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
        ? new BuyerDetails.fromJson(json['buyerDetails'])
        : null;
    sId = json['_id'];
    buyerId = json['buyerId'];
    profileId = json['profileId'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(new Products.fromJson(v));
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.buyerDetails != null) {
      data['buyerDetails'] = this.buyerDetails!.toJson();
    }
    data['_id'] = this.sId;
    data['buyerId'] = this.buyerId;
    data['profileId'] = this.profileId;
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    data['shipmentCharges'] = this.shipmentCharges;
    data['grandTotal'] = this.grandTotal;
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['address'] = this.address;
    data['additionalNote'] = this.additionalNote;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productId'] = this.productId;
    data['name'] = this.name;
    data['quantity'] = this.quantity;
    data['price'] = this.price;
    data['totalPrice'] = this.totalPrice;
    data['images'] = this.images;
    data['selectedColor'] = this.selectedColor;
    data['selectedSize'] = this.selectedSize;
    data['_id'] = this.sId;
    return data;
  }
}
