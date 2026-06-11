import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_brand/models/aiAssistant/AiAssistantModel.dart';
import 'package:new_brand/resources/global.dart';

class AiAssistantRepository {
  Future<AiAssistantModel> sendMessage({
    required String token,
    required String message,
    required List<Map<String, String>> history,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Global.sellerAiAssistant),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'message': message, 'history': history}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AiAssistantModel.fromJson(data);
      } else {
        return AiAssistantModel(
          message: data['message'] ?? 'Failed to get a response',
        );
      }
    } catch (e) {
      return AiAssistantModel(message: 'Error: $e');
    }
  }
}
