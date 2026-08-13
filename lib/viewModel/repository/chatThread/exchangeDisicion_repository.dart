// viewModel/repository/exchangeRepository/exchange_decision_repository.dart

import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';
import 'package:flutter/foundation.dart';

class ExchangeDecisionRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  Future<bool> makeDecision({
    required String exchangeId,
    required String decision,
    String? note,
  }) async {
    try {
      debugPrint("📤 Making exchange decision: $decision for ID: $exchangeId");

      final body = {
        "decision": decision,
        "note": note ?? "",
      };

      // ✅ Global.exchangeDecision is now a function
      final response = await apiServices.putApi(
        Global.exchangeDecision(exchangeId),
        body,
      );

      debugPrint("✅ Exchange decision response: $response");

      return response["success"] ?? false;
    } catch (e) {
      debugPrint("❌ Exchange decision error: $e");
      return false;
    }
  }
}
