import 'package:flutter/material.dart';
import 'package:new_brand/models/leaderboard/getLeaderboard_model.dart';
import 'package:new_brand/viewModel/repository/leaderboardRepository/getLeaderboard_repository.dart';

class GetLeaderboardProvider with ChangeNotifier {
  final GetLeaderboardRepository _repo = GetLeaderboardRepository();

  bool isLoading = false;
  bool isFetched = false;
  GetLeaderboardModel? leaderboardData;

  Future<void> getLeaderboardOnce({bool forceRefresh = false}) async {
    if (isFetched && !forceRefresh) return;

    try {
      isLoading = true;
      notifyListeners();

      leaderboardData = await _repo.getLeaderboard();
      isFetched = true;
    } catch (e) {
      debugPrint("Leaderboard Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
