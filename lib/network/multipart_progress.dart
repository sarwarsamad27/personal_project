import 'package:http/http.dart' as http;

/// Sends [request] while reporting fractional upload progress (0.0–1.0) via
/// [onProgress] as the encoded body is streamed out.
///
/// `http.MultipartRequest.send()` on its own gives no visibility into how
/// much of a large video has actually gone out over the wire — this
/// re-wraps the request's finalized byte stream (the encoded multipart
/// body built by `MultipartRequest.finalize()`) in a `StreamedRequest`,
/// counting bytes as they're consumed off that stream.
Future<http.StreamedResponse> sendMultipartWithProgress(
  http.MultipartRequest request, {
  required void Function(double progress) onProgress,
  Duration? timeout,
}) async {
  // MultipartRequest computes/sets contentLength as a side effect of
  // finalize() (it needs to encode field + file parts, boundaries and all,
  // to know the real byte length) — so it must be read AFTER finalize(),
  // not before.
  final byteStream = request.finalize();
  final total = request.contentLength;

  final streamedRequest = http.StreamedRequest(request.method, request.url)
    ..headers.addAll(request.headers)
    ..contentLength = total
    ..followRedirects = request.followRedirects
    ..maxRedirects = request.maxRedirects
    ..persistentConnection = request.persistentConnection;

  var sent = 0;
  byteStream.listen(
    (chunk) {
      sent += chunk.length;
      streamedRequest.sink.add(chunk);
      if (total > 0) onProgress((sent / total).clamp(0.0, 1.0));
    },
    onDone: () => streamedRequest.sink.close(),
    onError: (Object e, StackTrace st) => streamedRequest.sink.addError(e, st),
    cancelOnError: true,
  );

  // Mirrors http package's own BaseRequest.send(): close(force: false)
  // stops the client accepting new requests but lets the in-flight
  // response finish streaming, so it's safe to close right after send()
  // resolves rather than after the response body is fully read.
  final client = http.Client();
  try {
    final future = client.send(streamedRequest);
    return timeout != null ? await future.timeout(timeout) : await future;
  } finally {
    client.close();
  }
}
