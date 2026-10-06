import 'connectivity_status.dart';

/// Combines [NetworkInterfaceMonitor] (layer 1) and [ReachabilityProbe]
/// (layer 2) into one [ConnectivityStatus], for the connectivity banner and
/// for the [SyncOrchestrator]. A hint only: offline-first code never blocks
/// an action because of it.
abstract interface class ConnectivityService {
  ConnectivityStatus get status;
  Stream<ConnectivityStatus> get statusChanges;

  /// Starts listening to interface changes and checks once. Never awaited
  /// by the boot — it may touch the network.
  Future<void> start();

  /// Re-evaluates both layers now.
  Future<ConnectivityStatus> check();

  Future<void> dispose();
}
