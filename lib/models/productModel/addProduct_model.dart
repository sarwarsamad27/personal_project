class AddProductModel {
  String? message;
  Product? product;

  AddProductModel({this.message, this.product});

  AddProductModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    product =
        json['product'] != null ? new Product.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.product != null) {
      data['product'] = this.product!.toJson();
    }
    return data;
  }
}

class Product {
  String? profileId;
  String? categoryId;
  String? name;
  String? description;
  List<String>? images;
  int? beforeDiscountPrice;
  int? afterDiscountPrice;
  int? discountPercentage;
  List<String>? size;
  List<String>? color;
  int? stock;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Product(
      {this.profileId,
      this.categoryId,
      this.name,
      this.description,
      this.images,
      this.beforeDiscountPrice,
      this.afterDiscountPrice,
      this.discountPercentage,
      this.size,
      this.color,
      this.stock,
      this.sId,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Product.fromJson(Map<String, dynamic> json) {
    profileId = json['profileId'];
    categoryId = json['categoryId'];
    name = json['name'];
    description = json['description'];
    images = json['images'].cast<String>();
    beforeDiscountPrice = json['beforeDiscountPrice'];
    afterDiscountPrice = json['afterDiscountPrice'];
    discountPercentage = json['discountPercentage'];
    size = json['size'].cast<String>();
    color = json['color'].cast<String>();
    stock = json['stock'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['profileId'] = this.profileId;
    data['categoryId'] = this.categoryId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['images'] = this.images;
    data['beforeDiscountPrice'] = this.beforeDiscountPrice;
    data['afterDiscountPrice'] = this.afterDiscountPrice;
    data['discountPercentage'] = this.discountPercentage;
    data['size'] = this.size;
    data['color'] = this.color;
    data['stock'] = this.stock;
    data['_id'] = this.sId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
