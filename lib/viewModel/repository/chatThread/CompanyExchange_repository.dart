// viewModel/repository/chatThread/company_exchange_repository.dart

import 'dart:developer';

import 'package:new_brand/models/chatThread/exchangeRequestModel.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class CompanyExchangeRepository {
  final NetworkApiServices _api = NetworkApiServices();

  // List all exchange requests for this company
  Future<ExchangeRequestListModel> listRequests({String? status}) async {
    try {
      final query = status != null ? "?status=$status" : "";
      final response = await _api.getApi(
        "${Global.getCompanyExchangeRequests}$query",
      );
      log("${Global.getCompanyExchangeRequests}$query");
      log("Response: $response");
      return ExchangeRequestListModel.fromJson(response);
    } catch (e) {
      return ExchangeRequestListModel(message: "Error: $e");
    }
  }

  // Accept / Deny
  Future<bool> decide({
    required String exchangeId,
    required String decision, // "Accepted" | "Denied"
    required String resolutionType, // "replacement" | "refund"
    String note = "",
  }) async {
    try {
      final response = await _api.putApi(Global.exchangeDecision(exchangeId), {
        "decision": decision,
        "resolutionType": resolutionType,
        "note": note,
      });
      return response["success"] == true;
    } catch (e) {
      return false;
    }
  }

  // Mark return received
  Future<bool> markReceived(String exchangeId) async {
    try {
      final response = await _api.putApi(
        "${Global.exchangeBase}/$exchangeId/mark-received",
        {},
      );
      return response["success"] == true;
    } catch (e) {
      return false;
    }
  }

  // Start inspection
  Future<bool> startInspection(String exchangeId) async {
    try {
      final response = await _api.putApi(
        "${Global.exchangeBase}/$exchangeId/start-inspection",
        {},
      );
      return response["success"] == true;
    } catch (e) {
      return false;
    }
  }

  // Submit inspection result
  Future<bool> submitInspectionResult({
    required String exchangeId,
    required String result, // "approved" | "disputed"
    required String note,
  }) async {
    try {
      final response = await _api.putApi(
        "${Global.exchangeBase}/$exchangeId/inspection-result",
        {"result": result, "inspectionNote": note},
      );
      return response["success"] == true;
    } catch (e) {
      return false;
    }
  }

  // Ship replacement
  Future<bool> shipReplacement({
    required String exchangeId,
    required String trackingNumber,
    required String courierName,
  }) async {
    try {
      final response = await _api.putApi(
        "${Global.exchangeBase}/$exchangeId/ship-replacement",
        {"trackingNumber": trackingNumber, "courierName": courierName},
      );
      return response["success"] == true;
    } catch (e) {
      return false;
    }
  }

  // Process refund
  Future<bool> processRefund({
    required String exchangeId,
    required double refundAmount,
  }) async {
    try {
      final response = await _api.putApi(
        "${Global.exchangeBase}/$exchangeId/process-refund",
        {"refundAmount": refundAmount},
      );
      return response["success"] == true;
    } catch (e) {
      return false;
    }
  }

  // Mark completed
  Future<bool> markCompleted(String exchangeId) async {
    try {
      final response = await _api.putApi(
        "${Global.exchangeBase}/$exchangeId/complete",
        {},
      );
      return response["success"] == true;
    } catch (e) {
      return false;
    }
  }
}
