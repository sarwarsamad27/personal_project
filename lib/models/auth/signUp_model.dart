class SignUpModel {
  String? message;
  NewUser? newUser;

  SignUpModel({this.message, this.newUser});

  SignUpModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    newUser =
        json['newUser'] != null ? NewUser.fromJson(json['newUser']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (newUser != null) {
      data['newUser'] = newUser!.toJson();
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['password'] = password;
    data['_id'] = sId;
    data['__v'] = iV;
    return data;
  }
}
