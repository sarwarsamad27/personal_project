import 'package:flutter/material.dart';
import 'package:new_brand/models/sellerAnnouncement/getSellerAnnouncement_model.dart';
import 'package:new_brand/viewModel/repository/sellerAnnouncementRepository/getSellerAnnouncement_repository.dart';

class GetSellerAnnouncementProvider with ChangeNotifier {
  final GetSellerAnnouncementRepository _repo = GetSellerAnnouncementRepository();

  bool isLoading = false;
  bool isFetched = false;
  GetSellerAnnouncementModel? announcementData;

  Future<void> getAnnouncementsOnce({bool forceRefresh = false}) async {
    if (isLoading) return;
    if (isFetched && !forceRefresh) return;

    try {
      isLoading = true;
      notifyListeners();

      announcementData = await _repo.getAnnouncements();
      isFetched = true;
    } catch (e) {
      debugPrint("Seller Announcement Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
