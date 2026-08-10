class CreateProfileModel {
  String? message;
  Profile? profile;

  CreateProfileModel({this.message, this.profile});

  CreateProfileModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    profile =
        json['profile'] != null ? Profile.fromJson(json['profile']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (profile != null) {
      data['profile'] = profile!.toJson();
    }
    return data;
  }
}

class Profile {
  String? userId;
  String? image;
  String? name;
  String? email;
  String? phone;
  String? address;
  String? description;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;
   String? leopardsCityId;   // ✅ NEW
  String? leopardsCityName;

  Profile(
      {this.userId,
      this.image,
      this.name,
      this.email,
      this.phone,
      this.address,
      this.description,
      this.sId,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.leopardsCityId,
      this.leopardsCityName});

  Profile.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    image = json['image'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    address = json['address'];
    description = json['description'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    leopardsCityId = json['leopardsCityId'];     // ✅
    leopardsCityName = json['leopardsCityName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['image'] = image;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['address'] = address;
    data['description'] = description;
    data['_id'] = sId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['leopardsCityId'] = leopardsCityId;
    data['leopardsCityName'] = leopardsCityName;
    return data;
  }
}
