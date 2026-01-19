class ProfileScreenModel {
  String? message;
  Profile? profile;

  ProfileScreenModel({this.message, this.profile});

  ProfileScreenModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    profile =
        json['profile'] != null ? new Profile.fromJson(json['profile']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.profile != null) {
      data['profile'] = this.profile!.toJson();
    }
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
  List<String>? followers;
  int? followersCount;

  Profile(
      {this.sId,
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
      this.followersCount});

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
    fcmTokens = json['fcmTokens'].cast<String>();
    followers = json['followers'].cast<String>();
    followersCount = json['followersCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['userId'] = this.userId;
    data['image'] = this.image;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['address'] = this.address;
    data['description'] = this.description;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['fcmTokens'] = this.fcmTokens;
    data['followers'] = this.followers;
    data['followersCount'] = this.followersCount;
    return data;
  }
}
