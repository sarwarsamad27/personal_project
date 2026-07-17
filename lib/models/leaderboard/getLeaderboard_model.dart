class GetLeaderboardModel {
  String? message;
  int? badgeThreshold;
  int? page;
  int? limit;
  int? totalSellers;
  int? totalPages;
  List<SellerRank>? leaderboard;

  GetLeaderboardModel({
    this.message,
    this.badgeThreshold,
    this.page,
    this.limit,
    this.totalSellers,
    this.totalPages,
    this.leaderboard,
  });

  GetLeaderboardModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    badgeThreshold = json['badgeThreshold'] == null
        ? null
        : int.tryParse(json['badgeThreshold'].toString());
    page = json['page'] == null ? null : int.tryParse(json['page'].toString());
    limit = json['limit'] == null
        ? null
        : int.tryParse(json['limit'].toString());
    totalSellers = json['totalSellers'] == null
        ? null
        : int.tryParse(json['totalSellers'].toString());
    totalPages = json['totalPages'] == null
        ? null
        : int.tryParse(json['totalPages'].toString());
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
    data['page'] = page;
    data['limit'] = limit;
    data['totalSellers'] = totalSellers;
    data['totalPages'] = totalPages;
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
