class GetSingleProductModel {
  String? message;
  Product? product;
  int? totalReviews;
  List<Reviews>? reviews;

  GetSingleProductModel({
    this.message,
    this.product,
    this.totalReviews,
    this.reviews,
  });

  GetSingleProductModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    product = json['product'] != null
        ? Product.fromJson(json['product'])
        : null;
    totalReviews = json['totalReviews'];
    if (json['reviews'] != null) {
      reviews = <Reviews>[];
      json['reviews'].forEach((v) {
        reviews!.add(Reviews.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (product != null) {
      data['product'] = product!.toJson();
    }
    data['totalReviews'] = totalReviews;
    if (reviews != null) {
      data['reviews'] = reviews!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Product {
  String? sId;
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
  int? quantity;        // ✅ stock ki jagah
  int? weightInGrams;   // ✅ new
  String? createdAt;
  String? updatedAt;
  int? iV;

  Product({
    this.sId,
    this.profileId,
    this.categoryId,
    this.name,
    this.description,
    this.images,
    this.beforeDiscountPrice,
    this.afterDiscountPrice,
    this.discountPercentage,
    this.size,
    this.color,
    this.quantity,        // ✅
    this.weightInGrams,   // ✅
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Product.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    profileId = json['profileId'];
    categoryId = json['categoryId'];
    name = json['name'];
    description = json['description'];
    images = json['images'] != null
        ? List<String>.from(json['images'])
        : [];
    beforeDiscountPrice = json['beforeDiscountPrice'];
    afterDiscountPrice = json['afterDiscountPrice'];
    discountPercentage = json['discountPercentage'];
    size = json['size'] != null
        ? List<String>.from(json['size'])
        : [];
    color = json['color'] != null
        ? List<String>.from(json['color'])
        : [];
    quantity = json['quantity'];          // ✅
    weightInGrams = json['weightInGrams']; // ✅
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
    data['discountPercentage'] = discountPercentage;
    data['size'] = size;
    data['color'] = color;
    data['quantity'] = quantity;          // ✅
    data['weightInGrams'] = weightInGrams; // ✅
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class Reviews {
  Reply? reply;
  String? sId;
  String? productId;
  UserId? userId;
  int? stars;
  String? text;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Reviews({
    this.reply,
    this.sId,
    this.productId,
    this.userId,
    this.stars,
    this.text,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Reviews.fromJson(Map<String, dynamic> json) {
    reply = json['reply'] != null ? Reply.fromJson(json['reply']) : null;
    sId = json['_id'];
    productId = json['productId'];
    userId = json['userId'] != null
        ? UserId.fromJson(json['userId'])
        : null;
    stars = json['stars'];
    text = json['text'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (reply != null) {
      data['reply'] = reply!.toJson();
    }
    data['_id'] = sId;
    data['productId'] = productId;
    if (userId != null) {
      data['userId'] = userId!.toJson();
    }
    data['stars'] = stars;
    data['text'] = text;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class Reply {
  String? text;
  String? repliedAt;

  Reply({this.text, this.repliedAt});

  Reply.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    repliedAt = json['repliedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['repliedAt'] = repliedAt;
    return data;
  }
}

class UserId {
  String? sId;
  String? email;

  UserId({this.sId, this.email});

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['email'] = email;
    return data;
  }
}