class UpdateProfileModel {
  String? message;
  Profile? profile;

  UpdateProfileModel({this.message, this.profile});

  UpdateProfileModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    profile = json['profile'] != null
        ? new Profile.fromJson(json['profile'])
        : null;
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
    return data;
  }
}
