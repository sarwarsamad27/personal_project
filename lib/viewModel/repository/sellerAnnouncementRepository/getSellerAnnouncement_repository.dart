import 'package:new_brand/models/sellerAnnouncement/getSellerAnnouncement_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class GetSellerAnnouncementRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetSellerAnnouncements;

  Future<GetSellerAnnouncementModel> getAnnouncements() async {
    final response = await apiServices.cachedGetApi(
      'seller_announcements',
      apiUrl,
    );
    return GetSellerAnnouncementModel.fromJson(response);
  }
}
