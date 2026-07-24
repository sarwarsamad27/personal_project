import 'dart:convert';

import 'package:http/http.dart' as http;

/// POSTs [body] as JSON while reporting fractional upload progress
/// (0.0–1.0) via [onProgress] — for endpoints that embed large payloads
/// directly in JSON (e.g. base64-encoded reply images/video) where a plain
/// `http.post` gives no visibility into how much has gone out over the
/// wire. Streams the encoded body out in chunks instead of sending it as
/// one shot.
Future<http.Response> postJsonWithProgress(
  Uri url,
  Map<String, dynamic> body, {
  required Map<String, String> headers,
  required void Function(double progress) onProgress,
  Duration? timeout,
}) async {
  final payload = utf8.encode(jsonEncode(body));
  final total = payload.length;

  final request = http.StreamedRequest('POST', url)
    ..headers.addAll(headers)
    ..headers['Content-Type'] = 'application/json'
    ..contentLength = total;

  final client = http.Client();
  try {
    final responseFuture = client
        .send(request)
        .timeout(timeout ?? const Duration(seconds: 300));

    const chunkSize = 32 * 1024;
    var sent = 0;
    for (var i = 0; i < total; i += chunkSize) {
      final end = (i + chunkSize).clamp(0, total);
      request.sink.add(payload.sublist(i, end));
      sent = end;
      onProgress(total > 0 ? sent / total : 1.0);
      // Yield each chunk to the event loop so it's actually flushed
      // progressively instead of the whole body going out in one burst.
      await Future<void>.delayed(Duration.zero);
    }
    await request.sink.close();

    final streamedResponse = await responseFuture;
    return http.Response.fromStream(streamedResponse);
  } finally {
    client.close();
  }
}
