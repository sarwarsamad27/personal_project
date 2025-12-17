import 'package:new_brand/models/orders/pendingToDispatched_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class PendingToDispatchedRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  Future<PendingToDispatchedModel> pendingToDispatched({
    required String orderId,
        required String status,

    required String token,
  }) async {
    try {
      final url = Global.PendingToDispatched;

      // Multipart request for images
     
      final response = await apiServices.postApi(url, ({
         'orderId': orderId,
         'status': status
      })
      );
      print(response);

      return PendingToDispatchedModel.fromJson(response);
    } catch (e) {
      return PendingToDispatchedModel(message: "Error: $e");
    }
  }
}
