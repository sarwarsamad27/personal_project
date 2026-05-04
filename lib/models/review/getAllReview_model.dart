class GetCompanyReviewModel {
  String? message;
  List<Data>? data;

  GetCompanyReviewModel({this.message, this.data});

  GetCompanyReviewModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? reviewId;
  int? stars;
  String? text;
  List<String>? images;
  String? video;
  Product? product;
  User? user;
  String? createdAt;
  String? updatedAt;

  Data({
    this.reviewId,
    this.stars,
    this.text,
    this.images,
    this.video,
    this.product,
    this.user,
    this.createdAt,
    this.updatedAt,
  });

  Data.fromJson(Map<String, dynamic> json) {
    reviewId = json['reviewId'];
    stars = json['stars'];
    text = json['text'];
    images = json['images'] != null ? List<String>.from(json['images']) : [];
    video = json['video'];
    product = json['product'] != null ? Product.fromJson(json['product']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reviewId'] = reviewId;
    data['stars'] = stars;
    data['text'] = text;
    data['images'] = images;
    data['video'] = video;
    if (product != null) data['product'] = product!.toJson();
    if (user != null) data['user'] = user!.toJson();
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class Product {
  String? productId;
  String? name;
  Category? category;

  Product({this.productId, this.name, this.category});

  Product.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    name = json['name'];
    category = json['category'] != null
        ? new Category.fromJson(json['category'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productId'] = this.productId;
    data['name'] = this.name;
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    return data;
  }
}

class Category {
  String? categoryId;
  String? name;

  Category({this.categoryId, this.name});

  Category.fromJson(Map<String, dynamic> json) {
    categoryId = json['categoryId'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['categoryId'] = this.categoryId;
    data['name'] = this.name;
    return data;
  }
}

class User {
  String? userId;
  String? email;

  User({this.userId, this.email});

  User.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['email'] = this.email;
    return data;
  }
}
