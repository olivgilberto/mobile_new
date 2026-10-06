/// Layer 1: is there a network interface at all? Cheap, driven by OS
/// events — says nothing about the internet being reachable
/// (connectivity_plus in adapter_connectivity_connectivity_plus).
abstract interface class NetworkInterfaceMonitor {
  Future<bool> hasNetworkInterface();

  /// Emits whenever the interface availability changes.
  Stream<bool> get networkInterfaceChanges;
}
