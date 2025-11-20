import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:new_brand/exception/exceptions.dart';
import 'package:new_brand/network/base_api_services.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:http_parser/http_parser.dart';

class NetworkApiServices extends BaseApiServices {
  // ✅ Static headers (no token)
  Future<Map<String, String>> getHeaders({bool isMultipart = false}) async {
    final token = await LocalStorage.getToken();
    print("Token: $token"); // Debugging token value

    return {
      "Accept": "application/json",
      if (!isMultipart) "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  @override
  Future<Map<String, dynamic>> postApi(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await getHeaders(),
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
      final response = await http.get(
        Uri.parse(url),
        headers: await getHeaders(),
      );
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
        headers: await getHeaders(),
        body: jsonEncode(body),
      );

      return _handleResponse(url, response, body: body);
    } catch (e) {
      return _handleError(e);
    }
  }

Future<Map<String, dynamic>> postSingleImageApi(
  String url,
  Map<String, String> fields,
  File? image, {
  String fileFieldName = "image",
}) async {
  try {
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Correct Headers
    final token = await LocalStorage.getToken();
    request.headers.addAll({
      "Accept": "application/json",
      if (token != null && token.isNotEmpty)
        "Authorization": "Bearer $token",
    });

    // Add Text Fields
    request.fields.addAll(fields);

    // Add Image Properly
    if (image != null) {
      final mimeType = image.path.split(".").last.toLowerCase(); // jpg/png/jpeg

      request.files.add(
        await http.MultipartFile.fromPath(
          fileFieldName,
          image.path,
          contentType: MediaType("image", mimeType), // <-- IMPORTANT
        ),
      );
    }

    var streamed = await request.send();
    var response = await http.Response.fromStream(streamed);

    print("Upload Response: ${response.body}");

    return jsonDecode(response.body);
  } catch (e) {
    return {'code_status': false, 'message': 'Exception: $e'};
  }
}

  Future<Map<String, dynamic>> postMultipartApi(
    String url,
    Map<String, String> fields,
    List<File> images, {
    String fileFieldName = "images",
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add Authorization Header (IMPORTANT)
      final token = await LocalStorage.getToken();
      request.headers.addAll({
        "Accept": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      });

      // Add fields (text)
      request.fields.addAll(fields);

      // Add images
      for (var file in images) {
        request.files.add(
          await http.MultipartFile.fromPath(fileFieldName, file.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

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
      final response = await http.delete(
        Uri.parse(url),
        headers: await getHeaders(),
      );
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
