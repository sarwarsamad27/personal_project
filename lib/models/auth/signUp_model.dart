class SignUpModel {
  String? message;
  NewUser? newUser;

  SignUpModel({this.message, this.newUser});

  SignUpModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    newUser =
        json['newUser'] != null ? new NewUser.fromJson(json['newUser']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.newUser != null) {
      data['newUser'] = this.newUser!.toJson();
    }
    return data;
  }
}

class NewUser {
  String? email;
  String? password;
  String? sId;
  int? iV;

  NewUser({this.email, this.password, this.sId, this.iV});

  NewUser.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    password = json['password'];
    sId = json['_id'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['password'] = this.password;
    data['_id'] = this.sId;
    data['__v'] = this.iV;
    return data;
  }
}
