// models/auth/appleLogin_model.dart
class AppleLoginModel {
  String? message;
  String? token;
  AppleUser? user;

  AppleLoginModel({this.message, this.token, this.user});

  factory AppleLoginModel.fromJson(Map<String, dynamic> json) {
    return AppleLoginModel(
      message: json['message'],
      token: json['token'],
      user: json['user'] != null ? AppleUser.fromJson(json['user']) : null,
    );
  }
}

class AppleUser {
  String? id;
  String? email;
  bool? isAppleUser;

  AppleUser({this.id, this.email, this.isAppleUser});

  factory AppleUser.fromJson(Map<String, dynamic> json) {
    return AppleUser(
      id: json['id'],
      email: json['email'],
      isAppleUser: json['isAppleUser'],
    );
  }
}
