import 'dart:typed_data';

import 'package:adapter_http_dio/adapter_http_dio.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter({this.status, this.failure});
  final int? status;
  final DioExceptionType? failure;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? _, Future<void>? _) async {
    requests.add(options);
    if (failure case final type?) throw DioException(requestOptions: options, type: type);
    return ResponseBody.fromString('', status!);
  }

  @override
  void close({bool force = false}) {}
}

DioReachabilityProbe _probe(_Adapter adapter) => DioReachabilityProbe(
      baseUrl: 'https://api.example.com',
      path: '/v1/health',
      dio: Dio()..httpClientAdapter = adapter,
    );

void main() {
  test('any HTTP answer means reachable, even 404 or 503', () async {
    for (final status in [200, 404, 503]) {
      expect(await _probe(_Adapter(status: status)).isBackendReachable(), isTrue);
    }
  });

  test('transport failures mean unreachable, with a single HEAD and no retry', () async {
    for (final type in [DioExceptionType.connectionError, DioExceptionType.connectionTimeout]) {
      final adapter = _Adapter(failure: type);
      expect(await _probe(adapter).isBackendReachable(), isFalse);
      expect(adapter.requests.single.method, 'HEAD');
      expect(adapter.requests.single.path, '/v1/health');
    }
  });
}
