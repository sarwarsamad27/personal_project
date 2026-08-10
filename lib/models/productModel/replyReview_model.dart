class ReplyReviewModel {
  String? message;
  Reply? reply;

  ReplyReviewModel({this.message, this.reply});

  ReplyReviewModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    reply = json['reply'] != null ? Reply.fromJson(json['reply']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (reply != null) {
      data['reply'] = reply!.toJson();
    }
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
