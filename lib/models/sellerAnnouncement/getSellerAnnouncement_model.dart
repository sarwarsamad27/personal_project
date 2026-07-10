class GetSellerAnnouncementModel {
  String? message;
  List<SellerAnnouncement>? announcements;

  GetSellerAnnouncementModel({this.message, this.announcements});

  GetSellerAnnouncementModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['announcements'] != null) {
      announcements = <SellerAnnouncement>[];
      json['announcements'].forEach((v) {
        announcements!.add(SellerAnnouncement.fromJson(v));
      });
    }
  }
}

class SellerAnnouncement {
  String? id;
  String? title;
  String? description;
  String? icon; // gift | megaphone | star | trophy | sparkles | bell | calendar | heart
  String? type; // gift | announcement | general
  DateTime? eventDate;
  int? priority;

  SellerAnnouncement({
    this.id,
    this.title,
    this.description,
    this.icon,
    this.type,
    this.eventDate,
    this.priority,
  });

  SellerAnnouncement.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    title = json['title'];
    description = json['description'];
    icon = json['icon'];
    type = json['type'];
    eventDate = json['eventDate'] != null ? DateTime.tryParse(json['eventDate']) : null;
    priority = json['priority'] == null ? 0 : int.tryParse(json['priority'].toString()) ?? 0;
  }
}
