class GetMyOrders {
  String? message;
  String? profileId;
  int? page;
  int? limit;
  int? totalOrders;
  int? totalPages;
  List<Orders>? orders;

  GetMyOrders({
    this.message,
    this.profileId,
    this.page,
    this.limit,
    this.totalOrders,
    this.totalPages,
    this.orders,
  });

  GetMyOrders.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    profileId = json['profileId'];
    page = json['page'];
    limit = json['limit'];
    totalOrders = json['totalOrders'];
    totalPages = json['totalPages'];
    if (json['orders'] != null) {
      orders = <Orders>[];
      json['orders'].forEach((v) {
        orders!.add(new Orders.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['profileId'] = this.profileId;
    data['page'] = this.page;
    data['limit'] = this.limit;
    data['totalOrders'] = this.totalOrders;
    data['totalPages'] = this.totalPages;
    if (this.orders != null) {
      data['orders'] = this.orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Orders {
  String? sId;
  String? buyerId;
  String? profileId;
  List<Products>? products;
  int? shipmentCharges;
  int? grandTotal;
  BuyerDetails? buyerDetails;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Orders({
    this.sId,
    this.buyerId,
    this.profileId,
    this.products,
    this.shipmentCharges,
    this.grandTotal,
    this.buyerDetails,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Orders.fromJson(Map<String, dynamic> json) {
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
    buyerDetails = json['buyerDetails'] != null
        ? new BuyerDetails.fromJson(json['buyerDetails'])
        : null;
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['buyerId'] = this.buyerId;
    data['profileId'] = this.profileId;
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    data['shipmentCharges'] = this.shipmentCharges;
    data['grandTotal'] = this.grandTotal;
    if (this.buyerDetails != null) {
      data['buyerDetails'] = this.buyerDetails!.toJson();
    }
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
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
  String? status;
  String? categoryId;
  String? profileId;

  Products({
    this.productId,
    this.name,
    this.quantity,
    this.price,
    this.totalPrice,
    this.images,
    this.selectedColor,
    this.selectedSize,
    this.sId,
    this.status,
    this.categoryId,
    this.profileId,
  });

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
    status = json['status'];
    categoryId = json['categoryId'];
    profileId = json['profileId'];
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
    data['status'] = this.status;
    data['categoryId'] = this.categoryId;
    data['profileId'] = this.profileId;
    return data;
  }
}

class BuyerDetails {
  String? name;
  String? email;
  String? phone;
  String? address;
  String? additionalNote;

  BuyerDetails({
    this.name,
    this.email,
    this.phone,
    this.address,
    this.additionalNote,
  });

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
