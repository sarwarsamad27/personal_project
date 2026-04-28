import 'package:new_brand/models/courier/leopards_tracking_model.dart';
import 'package:new_brand/network/base_api_services.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class LeopardsTrackingRepository {
  final BaseApiServices apiService = NetworkApiServices();

  Future<List<LeopardsTrackingModel>> trackParcel(String trackNumber) async {
    try {
      final response = await apiService.getApi(
        Global.leopardsTrack(trackNumber),
      );
      if (response != null && response['status'] == 1) {
        final List data = response['data'] ?? [];
        return data.map((e) => LeopardsTrackingModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("❌ LeopardsTrackingRepository Error: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> requestPickup(String trackNumber) async {
    try {
      final response = await apiService.postApi(Global.leopardsRequestPickup, {
        "trackNumbers": [trackNumber],
      });
      return response ?? {"status": 0, "error": "No response from server"};
    } catch (e) {
      print("❌ requestPickup Error: $e");
      return {"status": 0, "error": e.toString()};
    }
  }
}
