import 'package:core/core.dart';
import 'package:dio/dio.dart';

/// Adds the bearer token when a [TokenProvider] is registered (i.e. once an
/// authentication module exists); otherwise sends the request unchanged.
class DioAuthInterceptor extends Interceptor {
  DioAuthInterceptor(this._tokenProvider);

  /// Resolved per request: the authentication module registers its
  /// TokenProvider after the core adapters, or not at all.
  final TokenProvider? Function() _tokenProvider;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenProvider()?.accessToken();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
}
