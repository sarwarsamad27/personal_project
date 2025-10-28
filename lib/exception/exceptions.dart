class AppException implements Exception {
  final String message;
  final String prefix;

  AppException({
    this.message = "",
    this.prefix = "",
  });

  @override
  String toString() => 'Message: $message, Prefix: $prefix';
}

class InternetException extends AppException {
  InternetException([String message = "No Internet connection"])
      : super(message: message, prefix: "Internet Error: ");
}

class RequestTimeout extends AppException {
  RequestTimeout([String message = "The request timed out"])
      : super(message: message, prefix: "Timeout Error: ");
}

class ServerException extends AppException {
  ServerException([String message = "Server error occurred"])
      : super(message: message, prefix: "Server Error: ");
}

class UnknownError extends AppException {
  UnknownError([String message = "An unknown error occurred"])
      : super(message: message, prefix: "Unknown Error: ");
}

class InvalidUrlException extends AppException {
  InvalidUrlException([String message = "The provided URL is invalid"])
      : super(message: message, prefix: "URL Error: ");
}
