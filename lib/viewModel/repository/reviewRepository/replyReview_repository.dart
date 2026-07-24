import 'dart:convert';

import 'package:new_brand/models/productModel/replyReview_model.dart';
import 'package:new_brand/network/json_progress.dart';
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
    void Function(double progress)? onProgress,
  }) async {
    try {
      final body = <String, dynamic>{
        "replyText": replyText,
        "reviewId": reviewId,
        if (replyImages.isNotEmpty) "replyImages": replyImages,
        if (replyVideo != null) "replyVideo": replyVideo,
      };

      if (onProgress == null) {
        final response = await apiServices.postApi(Global.ReplyReviews, body);
        return ReplyReviewModel.fromJson(response);
      }

      // Progress-tracked path — embedded base64 images/video can be large,
      // so stream the JSON body out in chunks instead of one-shot posting.
      final headers = await apiServices.getHeaders();
      final response = await postJsonWithProgress(
        Uri.parse(Global.ReplyReviews),
        body,
        headers: headers,
        onProgress: onProgress,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return ReplyReviewModel.fromJson(decoded);
      }
      return ReplyReviewModel(message: 'Server error: ${response.statusCode}');
    } catch (e) {
      return ReplyReviewModel(message: "Error: $e");
    }
  }
}
