import 'package:flutter/material.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/viewModel/repository/reviewRepository/replyReview_repository.dart';

class ReplyReviewProvider with ChangeNotifier {
  final ReplyReviewRepository repo = ReplyReviewRepository();

  bool isLoading = false;

  Future<bool> replyOnReview({
    required String reviewId,
    required String replyText,
  }) async {
    try {
      isLoading = true;
      notifyListeners();
      final token = await LocalStorage.getToken();
      final res = await repo.replyReview(
        replyText: replyText,
        reviewId: reviewId,
        token: token ?? '',
      );

      isLoading = false;
      notifyListeners();

      return res.reply != null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
