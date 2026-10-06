import 'dart:async';

import 'connectivity_service.dart';
import 'connectivity_status.dart';
import 'network_interface_monitor.dart';
import 'reachability_probe.dart';

/// Tech-free: lives in core because it only works through ports. The probe
/// runs only when an interface exists; while the backend does not answer
/// it is retried with exponential backoff ([minRecheckDelay] doubling up
/// to [maxRecheckDelay]).
class DefaultConnectivityService implements ConnectivityService {
  DefaultConnectivityService({
    required this._networkInterfaceMonitor,
    required this._reachabilityProbe,
    this.minRecheckDelay = const Duration(seconds: 15),
    this.maxRecheckDelay = const Duration(minutes: 5),
  }) : _nextRecheckDelay = minRecheckDelay;

  final NetworkInterfaceMonitor _networkInterfaceMonitor;
  final ReachabilityProbe _reachabilityProbe;
  final Duration minRecheckDelay;
  final Duration maxRecheckDelay;

  final _statusChanges = StreamController<ConnectivityStatus>.broadcast();
  StreamSubscription<bool>? _interfaceSubscription;
  Timer? _recheck;
  Duration _nextRecheckDelay;
  var _generation = 0;
  var _status = ConnectivityStatus.unknown;

  @override
  ConnectivityStatus get status => _status;

  @override
  Stream<ConnectivityStatus> get statusChanges => _statusChanges.stream;

  @override
  Future<void> start() async {
    _interfaceSubscription ??= _networkInterfaceMonitor.networkInterfaceChanges
        .listen((_) => unawaited(check()));
    await check();
  }

  @override
  Future<ConnectivityStatus> check() async {
    _recheck?.cancel();
    final generation = ++_generation;
    final next = !await _networkInterfaceMonitor.hasNetworkInterface()
        ? ConnectivityStatus.offline
        : await _reachabilityProbe.isBackendReachable()
            ? ConnectivityStatus.online
            : ConnectivityStatus.noInternet;
    // A newer check started meanwhile: its result wins.
    if (generation != _generation) return _status;

    if (next == ConnectivityStatus.noInternet) {
      _recheck = Timer(_nextRecheckDelay, () => unawaited(check()));
      final doubled = _nextRecheckDelay * 2;
      _nextRecheckDelay = doubled > maxRecheckDelay ? maxRecheckDelay : doubled;
    } else {
      _nextRecheckDelay = minRecheckDelay;
    }
    if (next != _status) {
      _status = next;
      _statusChanges.add(next);
    }
    return next;
  }

  @override
  Future<void> dispose() async {
    _recheck?.cancel();
    await _interfaceSubscription?.cancel();
    await _statusChanges.close();
  }
}
