import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:new_brand/exception/exceptions.dart';
import 'package:new_brand/network/base_api_services.dart';
import 'package:new_brand/resources/appNav.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/view/companySide/auth/loginScreen.dart';

class NetworkApiServices extends BaseApiServices {
  static bool _isRedirecting = false;

  Future<void> _forceLogoutToLogin() async {
    if (_isRedirecting) return;
    _isRedirecting = true;

    try {
      await LocalStorage.clearToken();
    } catch (_) {}

    final nav = appNavKey.currentState;
    if (nav != null) {
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }

    _isRedirecting = false;
  }

  // ✅ Static headers (with token)
  Future<Map<String, String>> getHeaders({bool isMultipart = false}) async {
    final token = await LocalStorage.getToken();
    if (kDebugMode) {
      print("Token: $token");
    }

    // ✅ Token missing -> logout
    if (token == null || token.isEmpty) {
      await _forceLogoutToLogin();
      return {
        "Accept": "application/json",
        if (!isMultipart) "Content-Type": "application/json",
      };
    }

    // ✅ Token expired (local check) -> logout
    try {
      final expired = JwtDecoder.isExpired(token);
      if (expired) {
        await _forceLogoutToLogin();
        return {
          "Accept": "application/json",
          if (!isMultipart) "Content-Type": "application/json",
        };
      }
    } catch (_) {
      // if token not a valid JWT, treat as invalid
      await _forceLogoutToLogin();
      return {
        "Accept": "application/json",
        if (!isMultipart) "Content-Type": "application/json",
      };
    }

    return {
      "Accept": "application/json",
      if (!isMultipart) "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<Map<String, String>> getHeadersNoAuth({bool isMultipart = false}) async {
    return {
      "Accept": "application/json",
      if (!isMultipart) "Content-Type": "application/json",
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
    Map<String, dynamic> body, {
    File? image,
    String fileFieldName = "image",
  }) async {
    try {
      // If image is provided, use multipart PUT
      if (image != null) {
        var request = http.MultipartRequest('PUT', Uri.parse(url));

        // Headers
        final headers = await getHeaders(isMultipart: true);
        request.headers.addAll(headers);

        // Add text fields
        body.forEach((key, value) {
          request.fields[key] = value.toString();
        });

        // Add image
        final mimeType = image.path.split('.').last.toLowerCase(); // jpg/png
        request.files.add(
          await http.MultipartFile.fromPath(
            fileFieldName,
            image.path,
            contentType: MediaType("image", mimeType),
          ),
        );

        // Send request
        var streamed = await request.send();
        var response = await http.Response.fromStream(streamed);

        if (kDebugMode) {
          print("PUT Multipart Response: ${response.body}");
        }

        // ✅ handle 401/403 same way
        return _handleResponse(url, response, body: body);
      } else {
        // Plain JSON PUT
        final response = await http.put(
          Uri.parse(url),
          headers: await getHeaders(),
          body: jsonEncode(body),
        );

        return _handleResponse(url, response, body: body);
      }
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> postApiNoAuth(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await getHeadersNoAuth(),
        body: jsonEncode(body),
      );
      return _handleResponse(url, response, body: body);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> putMultiPart({
    required String url,
    required Map<String, String> fields,
    required List<File> files,
    String fileFieldName = "images",
  }) async {
    try {
      var request = http.MultipartRequest('PUT', Uri.parse(url));

      // Add headers
      final headers = await getHeaders(isMultipart: true);
      request.headers.addAll(headers);

      // Add text fields
      request.fields.addAll(fields);

      // Add files
      for (var file in files) {
        final mimeType = file.path.split(".").last.toLowerCase();
        request.files.add(
          await http.MultipartFile.fromPath(
            fileFieldName,
            file.path,
            contentType: MediaType("image", mimeType),
          ),
        );
      }

      // Send request
      var streamed = await request.send();
      var response = await http.Response.fromStream(streamed);

      return _handleResponse(url, response);
    } catch (e) {
      return {'code_status': false, 'message': 'Exception: $e'};
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
      final headers = await getHeaders(isMultipart: true);
      request.headers.addAll(headers);

      // Add Text Fields
      request.fields.addAll(fields);

      // Add Image Properly
      if (image != null) {
        final mimeType = image.path.split(".").last.toLowerCase(); // jpg/png/jpeg

        request.files.add(
          await http.MultipartFile.fromPath(
            fileFieldName,
            image.path,
            contentType: MediaType("image", mimeType),
          ),
        );
      }

      var streamed = await request.send();
      var response = await http.Response.fromStream(streamed);

      if (kDebugMode) {
        print("Upload Response: ${response.body}");
      }

      return _handleResponse(url, response);
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
      final headers = await getHeaders(isMultipart: true);
      request.headers.addAll(headers);

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

      return _handleResponse(url, response);
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

    // ✅ Unauthorized -> logout + return
    if (response.statusCode == 401 || response.statusCode == 403) {
      // fire-and-forget (avoid making _handleResponse async)
      unawaited(_forceLogoutToLogin());
      return {
        'code_status': false,
        'message': 'Session expired. Please login again.',
      };
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
