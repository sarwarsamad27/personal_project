  class GetReturnedOrderModel {
    String? message;
    int? page;
    int? limit;
    int? totalOrders;
    int? totalPages;
    List<Orders>? orders;

    GetReturnedOrderModel(
        {this.message,
        this.page,
        this.limit,
        this.totalOrders,
        this.totalPages,
        this.orders});

    GetReturnedOrderModel.fromJson(Map<String, dynamic> json) {
      message = json['message'];
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
    String? profileId;
    List<Products>? products;
    int? shipmentCharges;
    int? grandTotal;
    BuyerDetails? buyerDetails;
    String? status;
    String? createdAt;
    String? updatedAt;
    int? iV;
    String? orderId;

    Orders(
        {this.sId,
        this.buyerId,
        this.profileId,
        this.products,
        this.shipmentCharges,
        this.grandTotal,
        this.buyerDetails,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.orderId,
        this.iV});

    Orders.fromJson(Map<String, dynamic> json) {
      sId = json['_id'];
      orderId = json['orderId'];
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
      buyerDetails = json['buyerDetails'] != null
          ? BuyerDetails.fromJson(json['buyerDetails'])
          : null;
      status = json['status'];
      createdAt = json['createdAt'];
      updatedAt = json['updatedAt'];
      iV = json['__v'];
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
      data['orderId'] = orderId;
      data['updatedAt'] = updatedAt;
      data['__v'] = iV;
      return data;
    }
  }

  class Products {
    String? productId;
    String? status;
    String? name;
    int? quantity;
    int? price;
    int? totalPrice;
    List<String>? images;
    List<String>? selectedColor;
    List<String>? selectedSize;
    String? sId;
    ProductDetails? productDetails;

    Products(
        {this.productId,
        this.status,
        this.name,
        this.quantity,
        this.price,
        this.totalPrice,
        this.images,
        this.selectedColor,
        this.selectedSize,
        this.sId,
        this.productDetails});

    Products.fromJson(Map<String, dynamic> json) {
      productId = json['productId'];
      status = json['status'];
      name = json['name'];
      quantity = json['quantity'];
      price = json['price'];
      totalPrice = json['totalPrice'];
      images = json['images'].cast<String>();
      selectedColor = json['selectedColor'].cast<String>();
      selectedSize = json['selectedSize'].cast<String>();
      sId = json['_id'];
      productDetails = json['productDetails'] != null
          ? ProductDetails.fromJson(json['productDetails'])
          : null;
    }

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['productId'] = productId;
      data['status'] = status;
      data['name'] = name;
      data['quantity'] = quantity;
      data['price'] = price;
      data['totalPrice'] = totalPrice;
      data['images'] = images;
      data['selectedColor'] = selectedColor;
      data['selectedSize'] = selectedSize;
      data['_id'] = sId;
      if (productDetails != null) {
        data['productDetails'] = productDetails!.toJson();
      }
      return data;
    }
  }

  class ProductDetails {
    String? sId;
    String? categoryId;
    String? name;
    List<String>? images;

    ProductDetails({this.sId, this.categoryId, this.name, this.images});

    ProductDetails.fromJson(Map<String, dynamic> json) {
      sId = json['_id'];
      categoryId = json['categoryId'];
      name = json['name'];
      images = json['images'].cast<String>();
    }

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['_id'] = sId;
      data['categoryId'] = categoryId;
      data['name'] = name;
      data['images'] = images;
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
