class ReplyReviewModel {
  String? message;
  Reply? reply;

  ReplyReviewModel({this.message, this.reply});

  ReplyReviewModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    reply = json['reply'] != null ? new Reply.fromJson(json['reply']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.reply != null) {
      data['reply'] = this.reply!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
    data['repliedAt'] = this.repliedAt;
    return data;
  }
}
