class CreateCategoryModel {
  String? message;
  Category? category;

  CreateCategoryModel({this.message, this.category});

  CreateCategoryModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    category = json['category'] != null
        ? Category.fromJson(json['category'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (category != null) {
      data['category'] = category!.toJson();
    }
    return data;
  }
}

class Category {
  String? profileId;
  String? name;
  String? image;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Category(
      {this.profileId,
      this.name,
      this.image,
      this.sId,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Category.fromJson(Map<String, dynamic> json) {
    profileId = json['profileId'];
    name = json['name'];
    image = json['image'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['profileId'] = profileId;
    data['name'] = name;
    data['image'] = image;
    data['_id'] = sId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
