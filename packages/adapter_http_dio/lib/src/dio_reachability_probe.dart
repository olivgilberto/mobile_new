import 'package:core/core.dart';
import 'package:dio/dio.dart';

/// [ReachabilityProbe] backed by Dio: a `HEAD` to the backend's health
/// endpoint on its own Dio instance — no Auth, Logging or Retry
/// interceptors, short timeouts. Any HTTP response (even 4xx/5xx) means the
/// backend answered; only transport failures mean it is unreachable.
class DioReachabilityProbe implements ReachabilityProbe {
  DioReachabilityProbe({
    required String baseUrl,
    required this.path,
    Duration timeout = const Duration(seconds: 3),
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options = _dio.options.copyWith(
      baseUrl: baseUrl,
      connectTimeout: timeout,
      sendTimeout: timeout,
      receiveTimeout: timeout,
      validateStatus: (_) => true,
    );
  }

  /// The backend's health endpoint (lightweight, unauthenticated, never
  /// touches the database).
  final String path;
  final Dio _dio;

  @override
  Future<bool> isBackendReachable() async {
    try {
      await _dio.head<void>(path);
      return true;
    } on DioException catch (exception) {
      return exception.response != null;
    }
  }
}
