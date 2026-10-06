import 'package:core/core.dart';
import 'package:dio/dio.dart';

/// Logs method, path, status and duration through core's [AppLogger].
/// Never logs headers or bodies (tokens and personal data).
class DioLoggingInterceptor extends Interceptor {
  DioLoggingInterceptor(this._logger);

  final AppLogger _logger;
  static const _startedAtKey = 'logging.startedAt';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedAtKey] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _logger.info('${_describe(response.requestOptions)} → '
        '${response.statusCode} (${_elapsed(response.requestOptions)} ms)');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.error(
      '${_describe(err.requestOptions)} → '
      '${err.response?.statusCode ?? err.type.name} '
      '(${_elapsed(err.requestOptions)} ms)',
      error: err.message,
    );
    handler.next(err);
  }

  String _describe(RequestOptions options) =>
      '${options.method} ${options.uri.path}';

  int _elapsed(RequestOptions options) {
    final startedAt = options.extra[_startedAtKey];
    return startedAt is DateTime
        ? DateTime.now().difference(startedAt).inMilliseconds
        : -1;
  }
}
