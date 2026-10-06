/// Layer 2: does the backend actually answer? A short request to the
/// backend's own health endpoint, without retries (adapter_http_dio). Any
/// HTTP response counts as reachable; only transport failures (timeout,
/// DNS, refused connection) do not. Never throws.
abstract interface class ReachabilityProbe {
  Future<bool> isBackendReachable();
}
