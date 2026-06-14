abstract class IApi {
  Future<T> getJson<T>(String path);
  Future<T> postJson<T>(String path, Map<String,dynamic> body);
}