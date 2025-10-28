import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:new_brand/exception/exceptions.dart';
import 'package:new_brand/network/base_api_services.dart';

class NetworkApiServices extends BaseApiServices {
  // ✅ Static headers (no token)
  Map<String, String> getHeaders() {
    return {"Accept": "application/json", "Content-Type": "application/json"};
  }

  @override
  Future<Map<String, dynamic>> postApi(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: getHeaders(),
        body: jsonEncode(body),
      );
      return _handleResponse(url, response, body: body);
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getApi(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: getHeaders());
      return _handleResponse(url, response);
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> putApi(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: getHeaders(),
        body: jsonEncode(body),
      );
      return _handleResponse(url, response, body: body);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ✅ Multi-image upload ke liye
  Future<Map<String, dynamic>> postMultipartApi(
    String url,
    Map<String, String> fields, // text fields
    List<File> images, { // multiple images
    String fileFieldName = "images", // backend ke hisaab se change karein
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add fields (jaise name, userId, etc.)
      request.fields.addAll(fields);

      // Add multiple images
      for (var file in images) {
        request.files.add(
          await http.MultipartFile.fromPath(
            fileFieldName, // 👈 agar backend `req.files.images` expect karta hai
            file.path,
          ),
        );
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print("✅ Multipart API URL: $url");
        print("✅ Fields: $fields");
        print("✅ Files: ${images.map((e) => e.path).toList()}");
        print("✅ Status Code: ${response.statusCode}");
        print("✅ Response Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'code_status': false,
          'message': 'Server Error: ${response.body}',
        };
      }
    } catch (e) {
      return {'code_status': false, 'message': 'Exception: $e'};
    }
  }

  @override
  Future<Map<String, dynamic>> deleteApi(String url) async {
    try {
      final response = await http.delete(Uri.parse(url), headers: getHeaders());
      return _handleResponse(url, response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Map<String, dynamic> _handleResponse(
    String url,
    http.Response response, {
    Map<String, dynamic>? body,
  }) {
    if (kDebugMode) {
      print('✅ API URL: $url');
    }
    // ignore: avoid_print
    if (body != null) print('✅ Request Body: ${jsonEncode(body)}');
    if (kDebugMode) {
      print('✅ Status Code: ${response.statusCode}');
      print('✅ Response Body: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else {
          return {'code_status': true, 'message': decoded.toString()};
        }
      } catch (e) {
        return {'code_status': true, 'message': response.body};
      }
    } else {
      return {
        'code_status': false,
        'message': 'Server Error: ${response.body}',
      };
    }
  }

  Map<String, dynamic> _handleError(e) {
    if (e is InternetException) {
      return {'code_status': false, 'message': 'No Internet Connection'};
    }
    return {'code_status': false, 'message': 'Exception: $e'};
  }
}
