class GetProductCategoryWiseModel {
  String? message;
  int? total;
  bool? isOrderBlocked;
  List<Products>? products;

  GetProductCategoryWiseModel({
    this.message,
    this.total,
    this.isOrderBlocked,
    this.products,
  });

  GetProductCategoryWiseModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    total = json['total'];
    isOrderBlocked = json['isOrderBlocked'] ?? false;
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['total'] = total;
    data['isOrderBlocked'] = isOrderBlocked;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Products {
  String? sId;
  String? profileId;
  String? categoryId;
  String? name;
  String? description;
  List<String>? images;
  int? beforeDiscountPrice;
  int? afterDiscountPrice;
  List<String>? size;
  List<String>? color;
  String? stock;
  int? quantity;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Products({
    this.sId,
    this.profileId,
    this.categoryId,
    this.name,
    this.description,
    this.images,
    this.beforeDiscountPrice,
    this.afterDiscountPrice,
    this.size,
    this.color,
    this.stock,
    this.quantity,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Products.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    profileId = json['profileId'];
    categoryId = json['categoryId'];
    name = json['name'];
    description = json['description'];
    images = json['images']?.cast<String>();
    beforeDiscountPrice = json['beforeDiscountPrice'];
    afterDiscountPrice = json['afterDiscountPrice'];
    size = json['size']?.cast<String>();
    color = json['color']?.cast<String>();
    stock = json['stock'];
    quantity = json['quantity'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['profileId'] = profileId;
    data['categoryId'] = categoryId;
    data['name'] = name;
    data['description'] = description;
    data['images'] = images;
    data['beforeDiscountPrice'] = beforeDiscountPrice;
    data['afterDiscountPrice'] = afterDiscountPrice;
    data['size'] = size;
    data['color'] = color;
    data['stock'] = stock;
    data['quantity'] = quantity;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
