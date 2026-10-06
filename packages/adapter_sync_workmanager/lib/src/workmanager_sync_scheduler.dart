import 'package:core/core.dart';
import 'package:workmanager/workmanager.dart';

/// Schedules the outbox sync as a workmanager periodic task (network
/// required), so pending operations sync even when the app is closed.
///
/// [callbackDispatcher] is the host app's top-level background entry point
/// (annotated `@pragma('vm:entry-point')`), which calls
/// [runWorkmanagerSyncTask].
class WorkmanagerSyncScheduler implements SyncScheduler {
  WorkmanagerSyncScheduler({
    required this._callbackDispatcher,
    this.frequency = const Duration(hours: 1),
    Workmanager? workmanager,
  }) : _workmanager = workmanager ?? Workmanager();

  /// Also the BGTaskScheduler identifier on iOS (Info.plist +
  /// AppDelegate registration must use the same value).
  static const taskName = 'outbox_sync';

  /// Android enforces a 15-minute minimum.
  final Duration frequency;
  final void Function() _callbackDispatcher;
  final Workmanager _workmanager;

  @override
  Future<void> schedulePeriodicSync() async {
    await _workmanager.initialize(_callbackDispatcher);
    await _workmanager.registerPeriodicTask(
      taskName,
      taskName,
      frequency: frequency,
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }
}

/// Called from the host app's background entry point. Runs [sync] whenever
/// the OS fires the task, so the host app never imports workmanager.
/// Returning `false` lets Android reschedule per its backoff policy.
void runWorkmanagerSyncTask(Future<bool> Function() sync) {
  Workmanager().executeTask((_, _) => sync());
}
