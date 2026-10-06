abstract interface class ApiError implements Exception {
  /// HTTP status, or null for transport errors (timeout, no connection).
  int? get statusCode;

  /// Decoded response body (e.g. the server state on a 409 Conflict).
  Object? get body;
}
