abstract class BaseApiServices {
  Future<dynamic> postApi(String url, Map<String, dynamic> body);
  Future<dynamic> getApi(String url, {bool suppressErrorToast = false});
  Future<dynamic> putApi(String url, Map<String, dynamic> body);
  Future<dynamic> deleteApi(String url);
}
