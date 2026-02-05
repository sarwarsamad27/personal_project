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
      AppToast.error("No active session found. Please login.");
      unawaited(_forceLogoutToLogin());
      return {
        "Accept": "application/json",
        if (!isMultipart) "Content-Type": "application/json",
      };
    }

    // ✅ local expiry check
    try {
      if (JwtDecoder.isExpired(token)) {
        AppToast.error("Session expired. Please login again.");
        unawaited(_forceLogoutToLogin());
        return {
          "Accept": "application/json",
          if (!isMultipart) "Content-Type": "application/json",
        };
      }
    } catch (_) {
      // invalid token => logout
      AppToast.error("Invalid session. Please login again.");
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

  Future<Map<String, String>> getHeadersNoAuth({
    bool isMultipart = false,
  }) async {
    return {
      "Accept": "application/json",
      if (!isMultipart) "Content-Type": "application/json",
    };
  }

  final int _timeoutDuration = 15;

  @override
  Future<Map<String, dynamic>> postApi(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: await getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: _timeoutDuration));
      return _handleResponse(url, response, body: body, method: 'POST');
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getApi(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: await getHeaders())
          .timeout(Duration(seconds: _timeoutDuration));
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

        final streamed = await request.send().timeout(
          Duration(seconds: _timeoutDuration),
        );
        final response = await http.Response.fromStream(streamed);

        if (kDebugMode) {
          print("PUT Multipart Response: ${response.body}");
        }

        return _handleResponse(url, response, body: body, method: 'PUT');
      } else {
        final response = await http
            .put(
              Uri.parse(url),
              headers: await getHeaders(),
              body: jsonEncode(body),
            )
            .timeout(Duration(seconds: _timeoutDuration));

        return _handleResponse(url, response, body: body, method: 'PUT');
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
      final response = await http
          .post(
            Uri.parse(url),
            headers: await getHeadersNoAuth(),
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: _timeoutDuration));
      return _handleResponse(url, response, body: body, method: 'POST');
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

      final streamed = await request.send().timeout(
        Duration(seconds: _timeoutDuration),
      );
      final response = await http.Response.fromStream(streamed);

      return _handleResponse(url, response, method: 'PUT');
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

      final streamed = await request.send().timeout(
        Duration(seconds: _timeoutDuration),
      );
      final response = await http.Response.fromStream(streamed);

      if (kDebugMode) {
        print("Upload Response: ${response.body}");
      }

      return _handleResponse(url, response, method: 'POST');
    } catch (e) {
      return _handleError(e);
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

      final streamedResponse = await request.send().timeout(
        Duration(seconds: _timeoutDuration),
      );
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(url, response, method: 'POST');
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> deleteApi(String url) async {
    try {
      final response = await http
          .delete(Uri.parse(url), headers: await getHeaders())
          .timeout(Duration(seconds: _timeoutDuration));
      return _handleResponse(url, response, method: 'DELETE');
    } catch (e) {
      return _handleError(e);
    }
  }

  Map<String, dynamic> _handleResponse(
    String url,
    http.Response response, {
    Map<String, dynamic>? body,
    String? method,
  }) {
    if (kDebugMode) {
      print('✅ API URL: $url');
      if (body != null) print('✅ Request Body: ${jsonEncode(body)}');
      print('✅ Status Code: ${response.statusCode}');
      print('✅ Response Body: ${response.body}');
    }

    // ✅ Unauthorized => logout + return response so UI loader can stop
    if (response.statusCode == 401 || response.statusCode == 403) {
      AppToast.error("Session expired. Please login again.");
      unawaited(_forceLogoutToLogin());
      return {
        'code_status': false,
        'message': 'Session expired. Please login again.',
      };
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final decoded = jsonDecode(response.body);
        String message = "Operation successful";

        if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('message')) {
            message = decoded['message'].toString();
          }

          // Show success toast for mutations
          if (method != null &&
              (method == 'POST' || method == 'PUT' || method == 'DELETE')) {
            AppToast.success(message);
          }

          return decoded;
        }

        if (method != null &&
            (method == 'POST' || method == 'PUT' || method == 'DELETE')) {
          AppToast.success(message);
        }
        return {'code_status': true, 'message': decoded.toString()};
      } catch (_) {
        return {'code_status': true, 'message': response.body};
      }
    }

    // Handle Error Responses (400, 500, etc)
    String errorMessage = "Server Error occurred";
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded.containsKey('message')) {
        errorMessage = decoded['message'].toString();
      } else {
        errorMessage = response.body;
      }
    } catch (_) {
      errorMessage = response.body;
    }

    AppToast.error(errorMessage);
    return {'code_status': false, 'message': errorMessage};
  }

  Map<String, dynamic> _handleError(e) {
    if (e is TimeoutException) {
      AppToast.error("Request Timeout. Please try again.");
      return {'code_status': false, 'message': 'Request Timeout'};
    }

    if (e is SocketException) {
      AppToast.error("No Internet Connection. Please check your network.");
      return {'code_status': false, 'message': 'No Internet Connection'};
    }

    if (e is HandshakeException) {
      AppToast.error("Security certificate error. Please try again later.");
      return {'code_status': false, 'message': 'Handshake Exception'};
    }

    if (e is InternetException) {
      AppToast.error("No Internet Connection. Please check your network.");
      return {'code_status': false, 'message': 'No Internet Connection'};
    }

    String msg = e.toString();
    if (msg.contains("Exception:")) {
      msg = msg.split("Exception:").last.trim();
    }
    AppToast.error(msg);
    return {'code_status': false, 'message': 'Exception: $e'};
  }
}
