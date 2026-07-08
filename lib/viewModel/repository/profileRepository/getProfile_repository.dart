import 'dart:developer';

import 'package:new_brand/models/profile/getSingleProfile_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class GetProfileRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetProfile;
  Future<ProfileScreenModel> getProfile() async {
    // A brand-new user has no profile yet, so the backend's 404 here is an
    // expected state, not an error — don't show the generic error toast for it.
    // Cached so offline launches can still see a previously-created profile
    // instead of being bounced back to the profile form.
    final response = await apiServices.cachedGetApi(
      'seller_profile',
      apiUrl,
      suppressErrorToast: true,
    );
    log(response.toString());
    return ProfileScreenModel.fromJson(response);
  }
}
