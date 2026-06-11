import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_brand/models/profile/AnalyzeStoreModel.dart';
import 'package:new_brand/resources/global.dart';

class AnalyzeStoreRepository {
  Future<AnalyzeStoreModel> analyzeStore({
    required String token,
    required String name,
    required String address,
    File? image,
    String? imageUrl,
    String? prompt,
    String? previousDescription,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Global.analyzeStoreProfile),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['name'] = name;
      request.fields['address'] = address;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        request.fields['imageUrl'] = imageUrl;
      }
      if (prompt != null && prompt.isNotEmpty) {
        request.fields['prompt'] = prompt;
      }
      if (previousDescription != null && previousDescription.isNotEmpty) {
        request.fields['previousDescription'] = previousDescription;
      }
      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', image.path),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      print(Global.analyzeStoreProfile);
      print("📡 Analyze Store Response status: ${response.statusCode}");
      print("📡 Analyze Store Response body: ${response.body}");
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AnalyzeStoreModel.fromJson(data);
      } else {
        return AnalyzeStoreModel(
          message: data['message'] ?? 'Failed to generate description',
        );
      }
    } catch (e) {
      return AnalyzeStoreModel(message: 'Error: $e');
    }
  }
}
