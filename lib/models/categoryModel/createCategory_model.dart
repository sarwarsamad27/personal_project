class CreateCategoryModel {
  String? message;
  Category? category;

  CreateCategoryModel({this.message, this.category});

  CreateCategoryModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    category = json['category'] != null
        ? new Category.fromJson(json['category'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.category != null) {
      data['category'] = this.category!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['profileId'] = this.profileId;
    data['name'] = this.name;
    data['image'] = this.image;
    data['_id'] = this.sId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
