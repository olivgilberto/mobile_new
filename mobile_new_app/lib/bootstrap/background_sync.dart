import 'package:adapter_sync_workmanager/adapter_sync_workmanager.dart';
import 'package:core/core.dart';
import 'package:firebase_core/firebase_core.dart';

import 'dependency_injection.dart';

/// Background entry point for the outbox sync. Runs in its own isolate, so
/// it rebuilds what the sync needs before running it.
@pragma('vm:entry-point')
void outboxSyncDispatcher() {
  runWorkmanagerSyncTask(() async {
    try {
      await Firebase.initializeApp();
      if (!getIt.isRegistered<OutboxSyncWorker>()) await configureDependencies();
      // False when a module has something left to retry.
      return await getIt<OutboxSyncWorker>().run();
    } catch (error, stackTrace) {
      if (getIt.isRegistered<AppLogger>()) {
        getIt<AppLogger>().error('Outbox sync failed', error: error, stackTrace: stackTrace);
      }
      return false; // Android reschedules with backoff
    }
  });
}
