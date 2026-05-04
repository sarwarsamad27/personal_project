class LoginModel {
  String? message;
  String? token;
  User? user;
  bool? suspended;
  String? suspendReason;
  String? suspendedUntil;

  LoginModel({this.message, this.token, this.user, this.suspended, this.suspendReason, this.suspendedUntil});

  LoginModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    token = json['token'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    suspended = json['suspended'] ?? false;
    suspendReason = json['suspendReason'];
    suspendedUntil = json['suspendedUntil'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['token'] = token;
    if (user != null) data['user'] = user!.toJson();
    data['suspended'] = suspended;
    data['suspendReason'] = suspendReason;
    data['suspendedUntil'] = suspendedUntil;
    return data;
  }
}

class User {
  String? id;
  String? email;

  User({this.id, this.email});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    return data;
  }
}
