import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_brand/models/productModel/AnalyzeProductModel.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:flutter/foundation.dart';

class AnalyzeProductRepository {
    final NetworkApiServices apiServices = NetworkApiServices();

  Future<AnalyzeProductModel> analyzeImage({
    required String token,
    required List<File> images,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Global.analyzeProductImage), // Global mein add karna
      );

      request.headers['Authorization'] = 'Bearer $token';
      for (final image in images) {
        request.files.add(await http.MultipartFile.fromPath('images', image.path));
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      debugPrint(Global.analyzeProductImage);
      debugPrint("📡 Analyze Response status: ${response.statusCode}");
      debugPrint("📡 Analyze Response body: ${response.body}");
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AnalyzeProductModel.fromJson(data);
      } else {
        return AnalyzeProductModel(
          message: data['message'] ?? 'Failed to analyze',
        );
      }
    } catch (e) {
      return AnalyzeProductModel(message: 'Error: $e');
    }
  }

  
}
