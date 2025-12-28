import 'package:flutter/material.dart';
import 'package:new_brand/models/review/getAllReview_model.dart';
import 'package:new_brand/viewModel/repository/reviewRepository/getAllReviewRepository.dart';

class CompanyReviewProvider with ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  List<Data> _reviews = [];
  List<Data> get reviews => _reviews;

  final GetAllReviewRepository repository = GetAllReviewRepository();

  Future<void> fetchReviews() async {
    _loading = true;
    notifyListeners();

    try {
      final response = await repository.getAllReview();
      _reviews = response.data ?? [];
    } catch (e) {
      _reviews = [];
      print("Error fetching reviews: $e");
    }

    _loading = false;
    notifyListeners();
  }
}
