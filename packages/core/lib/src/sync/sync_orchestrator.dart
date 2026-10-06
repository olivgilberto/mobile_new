import 'dart:async';

import '../connectivity/connectivity_service.dart';
import '../connectivity/connectivity_status.dart';
import 'outbox_sync_worker.dart';

/// Layer 3, foreground: decides *when* to sync while the app is open — on
/// every transition to [ConnectivityStatus.online], debounced. The
/// [OutboxSyncWorker] decides *what*; the `SyncScheduler` covers the app
/// being closed. One run at a time in this isolate; a run in the
/// background isolate at the same moment is made harmless by the
/// `Idempotency-Key` each outbox operation sends.
class SyncOrchestrator {
  SyncOrchestrator({
    required this._connectivityService,
    required this._outboxSyncWorker,
    this.debounce = const Duration(seconds: 2),
  });

  final ConnectivityService _connectivityService;
  final OutboxSyncWorker _outboxSyncWorker;
  final Duration debounce;

  StreamSubscription<ConnectivityStatus>? _subscription;
  Timer? _debounceTimer;
  Future<bool>? _running;

  /// Called at boot (after DI) once a feature module with an outbox
  /// exists, together with `SyncScheduler.schedulePeriodicSync()`.
  void start() {
    _subscription ??= _connectivityService.statusChanges
        .where((status) => status == ConnectivityStatus.online)
        .listen((_) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(debounce, () => unawaited(syncNow()));
    });
    if (_connectivityService.status == ConnectivityStatus.online) {
      unawaited(syncNow());
    }
  }

  /// Joins the run in progress instead of starting a second one.
  Future<bool> syncNow() =>
      _running ??= _outboxSyncWorker.run().whenComplete(() => _running = null);

  Future<void> dispose() async {
    _debounceTimer?.cancel();
    await _subscription?.cancel();
  }
}
