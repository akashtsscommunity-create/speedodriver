import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speedodriver/core/api/token_store.dart';
import 'package:speedodriver/app/constant.dart';

class ApiClient {
  final Dio _dio;
  final TokenStore _tokens;

  ApiClient(this._dio, this._tokens);

  Future<T> getJson<T>(String path) async {
    final r = await _dio.get(path);
    return r.data as T;
  }

  Future<T> postJson<T>(String path, Map<String, dynamic> body) async {
    final r = await _dio.post(path, data: body);
    return r.data as T;
  }

  Future<T> postJsonData<T>(String path, String data) async {
    final r = await _dio.post(path, data: data);
    return r.data as T;
  }

  Future<String> getText(String path) async {
    final r = await _dio.get(
      path,
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = (r.data as List<int>);
    return utf8.decode(bytes, allowMalformed: true);
  }

  Future<void> downloadToFile(
    String url,
    String savePath,
    void Function(int, int)? onProgress,
  ) async {
    await _dio.download(url, savePath, onReceiveProgress: onProgress);
  }

  Future<Uint8List> getBytes(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? query,
  }) async {
    final r = await _dio.get<List<int>>(
      path,
      queryParameters: query,
      options: Options(headers: headers, responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(r.data ?? const <int>[]);
  }

  Future<void> postBytes(
    String path,
    Uint8List bytes, {
    Map<String, String>? headers,
  }) async {
    await _dio.post(
      path,
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {
          'Content-Type': 'application/octet-stream',
          if (headers != null) ...headers,
        },
      ),
    );
  }

  int calculateTotalChunks(int fileSize, int chunkSize) {
    return (fileSize / chunkSize).ceil();
  }
  Stream<Uint8List> readFileInChunks(
      File file, {
        int chunkSize = 1024 * 1024,
      }) async* {
    final raf = await file.open();
    try {
      final fileLength = await file.length();
      int offset = 0;

      while (offset < fileLength) {
        final remaining = fileLength - offset;
        final bytesToRead = min(chunkSize, remaining);
        final bytes = await raf.read(bytesToRead);

        if (bytes.isEmpty) break;

        yield Uint8List.fromList(bytes);
        offset += bytes.length;
      }
    } finally {
      await raf.close();
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokens = ref.read(tokenStoreProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: Constant.baseUrl,
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (o, h) async {
        final t = await tokens.getAccessToken();
        if (t != null && t.isNotEmpty) o.headers['Authorization'] = 'Bearer $t';
        h.next(o);
      },
      onError: (e, h) async {
        if (e.response?.statusCode == 401) {
          final ok = await tokens.tryRefresh(ref);
          if (ok) {
            final req = e.requestOptions;
            final t = await tokens.getAccessToken();
            req.headers['Authorization'] = 'Bearer $t';
            final clone = await dio.fetch(req);
            h.resolve(clone);
            return;
          }
        }
        h.next(e);
      },
    ),
  );
  dio.interceptors.add(
    RetryInterceptor(
      dio: dio,
      retries: 3,
      retryDelays: const [
        Duration(milliseconds: 250),
        Duration(seconds: 1),
        Duration(seconds: 2),
      ],
    ),
  );
  return ApiClient(dio, tokens);
});
