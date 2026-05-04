import 'package:new_brand/models/productModel/replyReview_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class ReplyReviewRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  Future<ReplyReviewModel> replyReview({
    required String replyText,
    required String reviewId,
    required String token,
    List<String> replyImages = const [],
    String? replyVideo,
  }) async {
    try {
      final body = <String, dynamic>{
        "replyText": replyText,
        "reviewId": reviewId,
        if (replyImages.isNotEmpty) "replyImages": replyImages,
        if (replyVideo != null) "replyVideo": replyVideo,
      };
      final response = await apiServices.postApi(Global.ReplyReviews, body);
      return ReplyReviewModel.fromJson(response);
    } catch (e) {
      return ReplyReviewModel(message: "Error: $e");
    }
  }
}
