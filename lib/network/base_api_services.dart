abstract class BaseApiServices {
  Future<dynamic> postApi(String url, Map<String, dynamic> body);
  Future<dynamic> getApi(String url);
  Future<dynamic> putApi(String url, Map<String, dynamic> body);
  Future<dynamic> deleteApi(String url);
}
