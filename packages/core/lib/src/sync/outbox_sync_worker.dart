import '../logging/app_logger.dart';
import 'outbox_registry.dart';

/// Runs every module's [SyncableOutbox] registered in the [OutboxRegistry].
/// Tech-free, so it lives in core; *when* it runs is decided by a
/// `SyncScheduler` adapter (workmanager) and by connectivity. Each module
/// syncs in isolation: one failing never stops the others. Conflicts (409)
/// are recorded by each module in its `sync_conflicts` for manual
/// resolution — never resolved automatically.
class OutboxSyncWorker {
  OutboxSyncWorker({required this._registry, required this._logger});

  final OutboxRegistry _registry;
  final AppLogger _logger;

  /// True when every outbox is fully synced; false asks the scheduler to
  /// retry later (e.g. Android's backoff).
  Future<bool> run() async {
    var synced = true;
    for (final outbox in _registry.registered) {
      try {
        if (!await outbox.syncPending()) synced = false;
      } catch (error, stackTrace) {
        _logger.error('Outbox sync failed: ${outbox.name}', error: error, stackTrace: stackTrace);
        synced = false;
      }
    }
    return synced;
  }
}
