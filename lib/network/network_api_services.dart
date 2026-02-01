// network/network_api_services.dart
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
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/view/companySide/auth/loginScreen.dart';

class NetworkApiServices extends BaseApiServices {
  static bool _isRedirecting = false;

  // ✅ Global callable logout (SessionGuard uses it too)
  static Future<void> forceLogoutGlobal() async {
    final api = NetworkApiServices();
    await api._forceLogoutToLogin();
  }

  Future<void> _forceLogoutToLogin() async {
    if (_isRedirecting) return;
    _isRedirecting = true;

    try {
      // ✅ clear token first
      try {
        await LocalStorage.clearToken();
      } catch (_) {}

      void doNav() {
        final nav = appNavKey.currentState;
        if (nav == null) return;

        // ✅ Always use root navigator
        nav.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }

      // ✅ Navigation reliable even during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) => doNav());
      // also try immediate (works if already ready)
      doNav();
    } finally {
      // ✅ ALWAYS reset (even if nav null)
      _isRedirecting = false;
    }
  }

  // ✅ headers with auth
  Future<Map<String, String>> getHeaders({bool isMultipart = false}) async {
    final token = await LocalStorage.getToken();

    if (kDebugMode) {
      print("Token: $token");
    }

    // ✅ no token => logout + return no-auth headers
    if (token == null || token.isEmpty) {
      unawaited(_forceLogoutToLogin());
      return {
        "Accept": "application/json",
        if (!isMultipart) "Content-Type": "application/json",
      };
    }

    // ✅ local expiry check
    try {
      if (JwtDecoder.isExpired(token)) {
        unawaited(_forceLogoutToLogin());
        return {
          "Accept": "application/json",
          if (!isMultipart) "Content-Type": "application/json",
        };
      }
    } catch (_) {
      // invalid token => logout
      unawaited(_forceLogoutToLogin());
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
      if (image != null) {
        final request = http.MultipartRequest('PUT', Uri.parse(url));

        final headers = await getHeaders(isMultipart: true);
        request.headers.addAll(headers);

        body.forEach((key, value) {
          request.fields[key] = value.toString();
        });

        final mimeType = image.path.split('.').last.toLowerCase();
        request.files.add(
          await http.MultipartFile.fromPath(
            fileFieldName,
            image.path,
            contentType: MediaType("image", mimeType),
          ),
        );

        final streamed = await request.send();
        final response = await http.Response.fromStream(streamed);

        if (kDebugMode) {
          print("PUT Multipart Response: ${response.body}");
        }

        return _handleResponse(url, response, body: body);
      } else {
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
      final request = http.MultipartRequest('PUT', Uri.parse(url));

      final headers = await getHeaders(isMultipart: true);
      request.headers.addAll(headers);

      request.fields.addAll(fields);

      for (final file in files) {
        final mimeType = file.path.split(".").last.toLowerCase();
        request.files.add(
          await http.MultipartFile.fromPath(
            fileFieldName,
            file.path,
            contentType: MediaType("image", mimeType),
          ),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

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
      final request = http.MultipartRequest('POST', Uri.parse(url));

      final headers = await getHeaders(isMultipart: true);
      request.headers.addAll(headers);

      request.fields.addAll(fields);

      if (image != null) {
        final mimeType = image.path.split(".").last.toLowerCase();
        request.files.add(
          await http.MultipartFile.fromPath(
            fileFieldName,
            image.path,
            contentType: MediaType("image", mimeType),
          ),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

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
      final request = http.MultipartRequest('POST', Uri.parse(url));

      final headers = await getHeaders(isMultipart: true);
      request.headers.addAll(headers);

      request.fields.addAll(fields);

      for (final file in images) {
        request.files.add(
          await http.MultipartFile.fromPath(fileFieldName, file.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

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
      if (body != null) print('✅ Request Body: ${jsonEncode(body)}');
      print('✅ Status Code: ${response.statusCode}');
      print('✅ Response Body: ${response.body}');
    }

    // ✅ Unauthorized => logout + return response so UI loader can stop
    if (response.statusCode == 401 || response.statusCode == 403) {
      unawaited(_forceLogoutToLogin());
      return {
        'code_status': false,
        'message': 'Session expired. Please login again.',
      };
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
        return {'code_status': true, 'message': decoded.toString()};
      } catch (_) {
        return {'code_status': true, 'message': response.body};
      }
    }

    return {
      'code_status': false,
      'message': 'Server Error: ${response.body}',
    };
  }

  Map<String, dynamic> _handleError(e) {
    // ✅ internet off (real)
    if (e is SocketException) {
      try {
        AppToast.error("Your internet disconnected");
      } catch (_) {}
      return {'code_status': false, 'message': 'No Internet Connection'};
    }

    if (e is InternetException) {
      try {
        AppToast.error("Your internet disconnected");
      } catch (_) {}
      return {'code_status': false, 'message': 'No Internet Connection'};
    }

    return {'code_status': false, 'message': 'Exception: $e'};
  }
}
