class GoogleLoginModel {
  String? message;
  String? token;
  User? user;

  GoogleLoginModel({this.message, this.token, this.user});

  factory GoogleLoginModel.fromJson(Map<String, dynamic> json) {
    return GoogleLoginModel(
      message: json['message'],
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class User {
  String? id;
  String? email;
  bool? isGoogleUser;

  User({this.id, this.email, this.isGoogleUser});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      isGoogleUser: json['isGoogleUser'],
    );
  }
}
