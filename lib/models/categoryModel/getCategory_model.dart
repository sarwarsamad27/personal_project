class GetCategoryModel {
  String? message;
  List<Categories>? categories;

  GetCategoryModel({this.message, this.categories});

  GetCategoryModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Categories {
  String? sId;
  String? profileId;
  String? name;
  String? image;
  String? createdAt;
  String? updatedAt;
  int? iV;
  bool? hasLowStock;
  bool? hasOutOfStock;

  Categories({
    this.sId,
    this.profileId,
    this.name,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.hasLowStock,
    this.hasOutOfStock,
  });

  Categories.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    profileId = json['profileId'];
    name = json['name'];
    image = json['image'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    hasLowStock = json['hasLowStock'] ?? false;
    hasOutOfStock = json['hasOutOfStock'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['profileId'] = profileId;
    data['name'] = name;
    data['image'] = image;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['hasLowStock'] = hasLowStock;
    data['hasOutOfStock'] = hasOutOfStock;
    return data;
  }
}
