class GetLeaderboardModel {
  String? message;
  int? badgeThreshold;
  List<SellerRank>? leaderboard;

  GetLeaderboardModel({this.message, this.badgeThreshold, this.leaderboard});

  GetLeaderboardModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    badgeThreshold = json['badgeThreshold'] == null
        ? null
        : int.tryParse(json['badgeThreshold'].toString());
    if (json['leaderboard'] != null) {
      leaderboard = <SellerRank>[];
      json['leaderboard'].forEach((v) {
        leaderboard!.add(SellerRank.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    data['badgeThreshold'] = badgeThreshold;
    if (leaderboard != null) {
      data['leaderboard'] = leaderboard!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SellerRank {
  String? profileId;
  String? name;
  String? image;
  int? deliveredOrders;
  int? rank;
  String? badge; // "gold" | "silver" | "bronze" | null

  SellerRank({
    this.profileId,
    this.name,
    this.image,
    this.deliveredOrders,
    this.rank,
    this.badge,
  });

  SellerRank.fromJson(Map<String, dynamic> json) {
    profileId = json['profileId'];
    name = json['name'];
    image = json['image'];
    deliveredOrders = json['deliveredOrders'] == null
        ? 0
        : int.tryParse(json['deliveredOrders'].toString()) ?? 0;
    rank = json['rank'] == null ? null : int.tryParse(json['rank'].toString());
    badge = json['badge'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['profileId'] = profileId;
    data['name'] = name;
    data['image'] = image;
    data['deliveredOrders'] = deliveredOrders;
    data['rank'] = rank;
    data['badge'] = badge;
    return data;
  }
}
