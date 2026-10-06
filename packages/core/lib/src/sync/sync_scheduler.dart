/// Background sync scheduling port (workmanager in adapter_sync_workmanager).
abstract interface class SyncScheduler {
  /// Schedules the periodic background run of the outbox sync, so pending
  /// operations are sent even when the app is closed.
  Future<void> schedulePeriodicSync();
}
