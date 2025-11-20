import 'package:new_brand/models/profile/getSingleProfile_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class GetProfileRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetProfile;
  Future<ProfileScreenModel> getProfile() async {
    final response = await apiServices.getApi(apiUrl);

    return ProfileScreenModel.fromJson(response);
  }
}
