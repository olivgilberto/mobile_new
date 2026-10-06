import 'dart:math';

import 'package:dio/dio.dart';

/// Retries transient failures only (timeouts, no connection, 5xx) with
/// exponential backoff + jitter, at most [maxAttempts] attempts in total.
/// Never retries 4xx responses.
class DioRetryInterceptor extends Interceptor {
  DioRetryInterceptor(
    this._dio, {
    this.maxAttempts = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    Random? random,
  }) : _random = random ?? Random();

  final Dio _dio;
  final int maxAttempts;
  final Duration baseDelay;
  final Random _random;
  static const _attemptKey = 'retry.attempt';

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final attempt = (options.extra[_attemptKey] as int?) ?? 1;
    if (attempt >= maxAttempts || !_isTransient(err)) {
      handler.next(err);
      return;
    }
    await Future<void>.delayed(_delayFor(attempt));
    options.extra[_attemptKey] = attempt + 1;
    try {
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _isTransient(DioException err) => switch (err.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.connectionError =>
          true,
        DioExceptionType.badResponse => (err.response?.statusCode ?? 0) >= 500,
        _ => false,
      };

  /// baseDelay * 2^(attempt - 1), plus up to one baseDelay of random jitter.
  Duration _delayFor(int attempt) {
    final exponential = baseDelay * pow(2, attempt - 1).toInt();
    final jitter = baseDelay * _random.nextDouble();
    return exponential + jitter;
  }
}
