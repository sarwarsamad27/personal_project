import 'package:flutter/material.dart';
import 'package:new_brand/models/leaderboard/getLeaderboard_model.dart';
import 'package:new_brand/viewModel/repository/leaderboardRepository/getLeaderboard_repository.dart';

class GetLeaderboardProvider with ChangeNotifier {
  final GetLeaderboardRepository _repo = GetLeaderboardRepository();

  // ── Compact "Top 3" widget (profile screen) ─────────────────────────────
  bool isLoading = false;
  bool isFetched = false;
  GetLeaderboardModel? leaderboardData;

  Future<void> getLeaderboardOnce({bool forceRefresh = false}) async {
    if (isLoading) return;
    if (isFetched && !forceRefresh) return;

    try {
      isLoading = true;
      notifyListeners();

      leaderboardData = await _repo.getLeaderboard(page: 1, limit: 3);
      isFetched = true;
    } catch (e) {
      debugPrint("Leaderboard Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Full paginated list (See More screen) ───────────────────────────────
  static const int _pageSize = 20;

  final List<SellerRank> fullList = [];
  int _fullPage = 1;
  int? _fullTotalPages;
  String _fullSearch = "";
  bool isLoadingFullList = false;
  bool isLoadingMore = false;
  String? fullListError;
  int? badgeThreshold;

  bool get hasMore =>
      _fullTotalPages == null || _fullPage < (_fullTotalPages ?? 1);

  Future<void> loadFullListFirstPage({String search = ""}) async {
    _fullSearch = search;
    _fullPage = 1;
    _fullTotalPages = null;
    fullList.clear();
    fullListError = null;
    isLoadingFullList = true;
    notifyListeners();

    try {
      final data = await _repo.getLeaderboard(
        page: 1,
        limit: _pageSize,
        search: _fullSearch,
      );
      badgeThreshold = data.badgeThreshold;
      _fullTotalPages = data.totalPages;
      fullList.addAll(data.leaderboard ?? []);
    } catch (e) {
      fullListError = "Failed to load sellers";
      debugPrint("Leaderboard full list error: $e");
    } finally {
      isLoadingFullList = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreFullList() async {
    if (isLoadingMore || isLoadingFullList || !hasMore) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _fullPage + 1;
      final data = await _repo.getLeaderboard(
        page: nextPage,
        limit: _pageSize,
        search: _fullSearch,
      );
      _fullPage = nextPage;
      _fullTotalPages = data.totalPages;
      fullList.addAll(data.leaderboard ?? []);
    } catch (e) {
      debugPrint("Leaderboard load-more error: $e");
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }
}
