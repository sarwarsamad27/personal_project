import 'package:new_brand/models/chatThread/exchangeRequestModel.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class CompanyRefundRepository {
  final NetworkApiServices _api = NetworkApiServices();

  // ── List refund requests ───────────────────────────────────────
  Future<RefundRequestListModel> listRequests({String? status}) async {
    try {
      final query = status != null ? "?status=$status" : "";
      final response = await _api.getApi(
        "${Global.getCompanyRefundRequests}$query",
      );
      return RefundRequestListModel.fromJson(response);
    } catch (e) {
      return RefundRequestListModel(message: "Error: $e");
    }
  }

  // ── Accept / Reject ────────────────────────────────────────────
  Future<bool> decide({
    required String refundId,
    required String decision,
    String note = "",
  }) async {
    try {
      final response = await _api.putApi(
        Global.refundDecision(refundId),
        {"decision": decision, "note": note},
      );
      return response["success"] == true;
    } catch (e) {
      return false;
    }
  }

  // ── Mark return received ───────────────────────────────────────
  Future<bool> markReceived(String refundId) async {
    try {
      final response = await _api.putApi(
        Global.refundMarkReceived(refundId),
        {},
      );
      return response["success"] == true;
    } catch (e) {
      return false;
    }
  }

  // ── Start inspection ───────────────────────────────────────────
  Future<bool> startInspection(String refundId) async {
    try {
      final response = await _api.putApi(
        Global.refundStartInspection(refundId),
        {},
      );
      return response["success"] == true;
    } catch (e) {
      return false;
    }
  }

  // ── Inspection result ──────────────────────────────────────────
  Future<bool> submitInspectionResult({
    required String refundId,
    required String result,
    required String note,
  }) async {
    try {
      final response = await _api.putApi(
        Global.refundInspectionResult(refundId),
        {"result": result, "inspectionNote": note},
      );
      return response["success"] == true;
    } catch (e) {
      return false;
    }
  }

  // ── Finalize refund (wallet credit) ───────────────────────────
  Future<bool> finalizeRefund(String refundId) async {
    try {
      final response = await _api.putApi(
        Global.refundFinalize(refundId),
        {},
      );
      return response["success"] == true;
    } catch (e) {
      return false;
    }
  }
}