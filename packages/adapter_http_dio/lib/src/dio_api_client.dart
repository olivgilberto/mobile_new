import 'package:core/core.dart';
import 'package:dio/dio.dart';

import 'dio_api_error.dart';
import 'interceptors/dio_auth_interceptor.dart';
import 'interceptors/dio_logging_interceptor.dart';
import 'interceptors/dio_retry_interceptor.dart';

/// ApiClient backed by Dio, with Auth, Logging and Retry (exponential
/// backoff + jitter, max 3 attempts, transient errors only) interceptors.
/// Never a cache interceptor. Every [DioException] is translated into a
/// [DioApiError] before leaving this class.
class DioApiClient implements ApiClient {
  DioApiClient({
    required String baseUrl,
    required TokenProvider? Function() tokenProvider,
    required AppLogger logger,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options = _dio.options.copyWith(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );
    _dio.interceptors.addAll([
      DioAuthInterceptor(tokenProvider),
      DioLoggingInterceptor(logger),
      DioRetryInterceptor(_dio),
    ]);
  }

  final Dio _dio;

  @override
  Future<Object?> get(String path, {Map<String, String>? query}) =>
      _send(() => _dio.get<Object?>(path, queryParameters: query));

  @override
  Future<Object?> post(String path, {Object? body, String? idempotencyKey}) =>
      _send(() => _dio.post<Object?>(path, data: body, options: _options(idempotencyKey)));

  @override
  Future<Object?> put(String path, {Object? body, String? idempotencyKey}) =>
      _send(() => _dio.put<Object?>(path, data: body, options: _options(idempotencyKey)));

  @override
  Future<Object?> patch(String path, {Object? body, String? idempotencyKey}) =>
      _send(() => _dio.patch<Object?>(path, data: body, options: _options(idempotencyKey)));

  @override
  Future<Object?> delete(String path, {String? idempotencyKey}) =>
      _send(() => _dio.delete<Object?>(path, options: _options(idempotencyKey)));

  /// The Retry interceptor resends the same options, so a retried request
  /// keeps its key.
  Options? _options(String? idempotencyKey) => idempotencyKey == null
      ? null
      : Options(headers: {'Idempotency-Key': idempotencyKey});

  Future<Object?> _send(Future<Response<Object?>> Function() request) async {
    try {
      return (await request()).data;
    } on DioException catch (exception) {
      throw DioApiError.from(exception);
    }
  }
}
