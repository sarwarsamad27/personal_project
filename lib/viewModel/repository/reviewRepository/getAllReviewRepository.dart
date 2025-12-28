import 'package:new_brand/models/review/getAllReview_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class GetAllReviewRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetCompanyReviews;
  Future<GetCompanyReviewModel> getAllReview() async {
    final response = await apiServices.getApi(apiUrl);

    return GetCompanyReviewModel.fromJson(response);
  }
}
