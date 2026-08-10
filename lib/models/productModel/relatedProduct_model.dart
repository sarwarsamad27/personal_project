class RelatedProductModel {
  String? message;
  int? total;
  List<RelatedProducts>? relatedProducts;

  RelatedProductModel({this.message, this.total, this.relatedProducts});

  RelatedProductModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    total = json['total'];
    if (json['relatedProducts'] != null) {
      relatedProducts = <RelatedProducts>[];
      json['relatedProducts'].forEach((v) {
        relatedProducts!.add(RelatedProducts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['total'] = total;
    if (relatedProducts != null) {
      data['relatedProducts'] =
          relatedProducts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RelatedProducts {
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
  String? createdAt;
  String? updatedAt;
  int? iV;

  RelatedProducts(
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

  RelatedProducts.fromJson(Map<String, dynamic> json) {
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
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
