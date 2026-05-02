class ProfileScreenModel {
  String? message;
  Profile? profile;

  ProfileScreenModel({this.message, this.profile});

  ProfileScreenModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    profile = json['profile'] != null
        ? Profile.fromJson(json['profile'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    if (profile != null) data['profile'] = profile!.toJson();
    return data;
  }
}

class Profile {
  String? sId;
  String? userId;
  String? image;
  String? name;
  String? email;
  String? phone;
  String? address;
  String? description;
  String? createdAt;
  String? updatedAt;
  int? iV;
  List<String>? fcmTokens;
  List<dynamic>? followers;
  int? followersCount;
  int? leopardsCityId; // ← new
  String? leopardsCityName; // ← new

  Profile({
    this.sId,
    this.userId,
    this.image,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.fcmTokens,
    this.followers,
    this.followersCount,
    this.leopardsCityId,
    this.leopardsCityName,
  });

  Profile.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    image = json['image'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    address = json['address'];
    description = json['description'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    fcmTokens = (json['fcmTokens'] as List?)?.cast<String>();
    followers = (json['followers'] as List?)?.cast<dynamic>();
    followersCount = json['followersCount'];
    leopardsCityId = json['leopardsCityId']; // ← new
    leopardsCityName = json['leopardsCityName']; // ← new
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['_id'] = sId;
    data['userId'] = userId;
    data['image'] = image;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['address'] = address;
    data['description'] = description;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['fcmTokens'] = fcmTokens;
    data['followers'] = followers;
    data['followersCount'] = followersCount;
    data['leopardsCityId'] = leopardsCityId; // ← new
    data['leopardsCityName'] = leopardsCityName; // ← new
    return data;
  }
}
