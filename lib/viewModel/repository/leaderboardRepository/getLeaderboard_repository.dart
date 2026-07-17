import 'package:new_brand/models/leaderboard/getLeaderboard_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class GetLeaderboardRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetSellerLeaderboard;

  Future<GetLeaderboardModel> getLeaderboard({
    int page = 1,
    int limit = 3,
    String search = "",
  }) async {
    final query = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (search.trim().isNotEmpty) 'search': search.trim(),
    };
    final uri = Uri.parse(apiUrl).replace(queryParameters: query);

    // Cache key must include page/limit/search — a single shared key would
    // otherwise serve page 2 (or a search result) the cached page 1 list.
    final cacheKey = 'seller_leaderboard_p${page}_l$limit${search.trim().isEmpty ? '' : '_${search.trim().toLowerCase()}'}';

    final response = await apiServices.cachedGetApi(cacheKey, uri.toString());
    return GetLeaderboardModel.fromJson(response);
  }
}
