/// Implemented and registered by auth_module (dependency inversion).
abstract interface class TokenProvider {
  Future<String?> accessToken();
}
