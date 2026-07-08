import 'package:new_brand/models/leaderboard/getLeaderboard_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class GetLeaderboardRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetSellerLeaderboard;

  Future<GetLeaderboardModel> getLeaderboard() async {
    final response = await apiServices.cachedGetApi(
      'seller_leaderboard',
      apiUrl,
    );
    return GetLeaderboardModel.fromJson(response);
  }
}
