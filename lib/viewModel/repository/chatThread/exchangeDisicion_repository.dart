// viewModel/repository/exchangeRepository/exchange_decision_repository.dart

import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class ExchangeDecisionRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
final String baseUrl = Global.exchangeDecision;
  Future<bool> makeDecision({
    required String exchangeId,
    required String decision,

    String? note,
  }) async {
    try {
      print("📤 Making exchange decision: $decision for ID: $exchangeId");

      final body = {
        "decision": decision,
        "note": note ?? "",
      };

      final response = await apiServices.putApi(
        "${Global.exchangeDecision}/$exchangeId/decision",
        body,
      );

      print("✅ Exchange decision response: $response");

      return response["success"] ?? false;
    } catch (e) {
      print("❌ Exchange decision error: $e");
      return false;
    }
  }
}