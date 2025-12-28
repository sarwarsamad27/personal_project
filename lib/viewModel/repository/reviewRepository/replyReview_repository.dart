import 'package:new_brand/models/productModel/replyReview_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class ReplyReviewRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  Future<ReplyReviewModel> replyReview({
    required String replyText,
    required String reviewId,
    required String token,
  }) async {
    try {
      final url = Global.ReplyReviews;

      final response = await apiServices.postApi(url, ({
        "replyText": replyText,
        "reviewId": reviewId,
      }));
      print(response);

      return ReplyReviewModel.fromJson(response);
    } catch (e) {
      return ReplyReviewModel(message: "Error: $e");
    }
  }
}
