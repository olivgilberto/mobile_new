import 'dart:convert';
import 'dart:typed_data';

import 'package:adapter_http_dio/adapter_http_dio.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.statuses);
  final List<int> statuses;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? _, Future<void>? _) async {
    requests.add(options);
    final status = statuses[requests.length - 1];
    return ResponseBody.fromString(jsonEncode({'status': status}), status,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
  }

  @override
  void close({bool force = false}) {}
}

class _Logger implements AppLogger {
  final lines = <String>[];
  @override
  void info(String message) => lines.add(message);
  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) => lines.add('E $message');
}

class _Token implements TokenProvider {
  @override
  Future<String?> accessToken() async => 'abc';
}

DioApiClient _client(_ScriptedAdapter adapter, {TokenProvider? token, AppLogger? logger}) =>
    DioApiClient(
      baseUrl: 'https://api.example.com',
      tokenProvider: () => token,
      logger: logger ?? _Logger(),
      dio: Dio()..httpClientAdapter = adapter,
    );

void main() {
  test('retries 5xx then succeeds', () async {
    final adapter = _ScriptedAdapter([503, 200]);
    expect(await _client(adapter).get('/v1/items'), {'status': 200});
    expect(adapter.requests, hasLength(2));
  });

  test('gives up after 3 attempts and throws ApiError', () async {
    final adapter = _ScriptedAdapter([500, 502, 503, 200]);
    await expectLater(_client(adapter).get('/v1/items'),
        throwsA(isA<ApiError>().having((e) => e.statusCode, 'statusCode', 503)));
    expect(adapter.requests, hasLength(3));
  });

  test('never retries 4xx; body available on ApiError', () async {
    final adapter = _ScriptedAdapter([409]);
    await expectLater(_client(adapter).put('/v1/items/1', body: {'v': 1}),
        throwsA(isA<ApiError>()
            .having((e) => e.statusCode, 'statusCode', 409)
            .having((e) => e.body, 'body', {'status': 409})));
    expect(adapter.requests, hasLength(1));
  });

  test('adds bearer token only when a TokenProvider exists', () async {
    final withToken = _ScriptedAdapter([200]);
    await _client(withToken, token: _Token()).get('/v1/me');
    expect(withToken.requests.single.headers['Authorization'], 'Bearer abc');

    final withoutToken = _ScriptedAdapter([200]);
    await _client(withoutToken).get('/v1/me');
    expect(withoutToken.requests.single.headers.containsKey('Authorization'), isFalse);
  });

  test('logs method, path and status, never the body', () async {
    final logger = _Logger();
    await _client(_ScriptedAdapter([200]), logger: logger).post('/v1/items', body: {'secret': 'x'});
    expect(logger.lines.single, startsWith('POST /v1/items → 200'));
    expect(logger.lines.single, isNot(contains('secret')));
  });

  test('sends the Idempotency-Key, and keeps it when retrying', () async {
    final adapter = _ScriptedAdapter([503, 200]);
    await _client(adapter).put('/v1/items/1', body: {'name': 'x'}, idempotencyKey: 'op-1');
    expect(adapter.requests.map((r) => r.headers['Idempotency-Key']), ['op-1', 'op-1']);
  });

  test('no Idempotency-Key header unless one is given', () async {
    final adapter = _ScriptedAdapter([200]);
    await _client(adapter).post('/v1/items', body: {'name': 'x'});
    expect(adapter.requests.single.headers.containsKey('Idempotency-Key'), isFalse);
  });
}
