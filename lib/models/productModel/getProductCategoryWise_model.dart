class GetProductCategoryWiseModel {
  String? message;
  int? total;
  List<Products>? products;

  GetProductCategoryWiseModel({this.message, this.total, this.products});

  GetProductCategoryWiseModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    total = json['total'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(new Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['total'] = this.total;
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
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
  int? stock;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Products(
      {this.sId,
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
      this.createdAt,
      this.updatedAt,
      this.iV});

  Products.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    profileId = json['profileId'];
    categoryId = json['categoryId'];
    name = json['name'];
    description = json['description'];
    images = json['images'].cast<String>();
    beforeDiscountPrice = json['beforeDiscountPrice'];
    afterDiscountPrice = json['afterDiscountPrice'];
    size = json['size'].cast<String>();
    color = json['color'].cast<String>();
    stock = json['stock'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['profileId'] = this.profileId;
    data['categoryId'] = this.categoryId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['images'] = this.images;
    data['beforeDiscountPrice'] = this.beforeDiscountPrice;
    data['afterDiscountPrice'] = this.afterDiscountPrice;
    data['size'] = this.size;
    data['color'] = this.color;
    data['stock'] = this.stock;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
