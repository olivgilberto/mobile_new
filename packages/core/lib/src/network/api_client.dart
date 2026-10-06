/// HTTP port. Implemented in adapter_http_dio (Dio); modules never import dio.
/// Every method throws an [ApiError] on failure.
///
/// [idempotencyKey] is sent as the `Idempotency-Key` header. Outbox
/// operations always pass their own id, so a repeated send (retry, or the
/// foreground and background isolates syncing at the same time) is applied
/// once by the backend.
abstract interface class ApiClient {
  Future<Object?> get(String path, {Map<String, String>? query});
  Future<Object?> post(String path, {Object? body, String? idempotencyKey});
  Future<Object?> put(String path, {Object? body, String? idempotencyKey});
  Future<Object?> patch(String path, {Object? body, String? idempotencyKey});
  Future<Object?> delete(String path, {String? idempotencyKey});
}
