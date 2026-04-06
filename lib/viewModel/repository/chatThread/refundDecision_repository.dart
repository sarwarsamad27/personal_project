import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class RefundDecisionRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  Future<bool> makeDecision({
    required String refundId,
    required String decision,
    String? note,
  }) async {
    try {
      final body = {"decision": decision, "note": note ?? ""};
      final response = await apiServices.putApi(
        Global.refundDecision(refundId),
        body,
      );
      return response["success"] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateStatus({
    required String refundId,
    required String status,
    String? note,
  }) async {
    try {
      final body = {"status": status, "note": note ?? ""};
      final response = await apiServices.putApi(
        Global.updateRefundStatus(refundId),
        body,
      );
      return response["success"] ?? false;
    } catch (e) {
      return false;
    }
  }
}
