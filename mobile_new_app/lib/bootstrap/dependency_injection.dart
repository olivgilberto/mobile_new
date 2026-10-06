import 'package:adapter_connectivity_connectivity_plus/adapter_connectivity_connectivity_plus.dart';
import 'package:adapter_db_sqlcipher/adapter_db_sqlcipher.dart';
import 'package:adapter_http_dio/adapter_http_dio.dart';
import 'package:adapter_logging_crashlytics/adapter_logging_crashlytics.dart';
import 'package:adapter_prefs_shared_preferences/adapter_prefs_shared_preferences.dart';
import 'package:adapter_sync_workmanager/adapter_sync_workmanager.dart';
import 'package:core/core.dart';
import 'package:get_it/get_it.dart';

import 'background_sync.dart';

final getIt = GetIt.instance;

/// Provided per flavor via --dart-define-from-file (never hardcoded).
const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

/// PLACEHOLDER — replace with the backend's real health endpoint path
/// (lightweight, unauthenticated, never touches the database). Until then
/// the probe still works, since any HTTP answer (even 404) counts as
/// reachable, but it adds noise to the backend's logs.
const _healthCheckPath = '/v1/health';

/// Composition root. Order: core ports bound to their adapters (and core's
/// tech-free defaults) → feature modules, as they are created.
Future<void> configureDependencies() async {
  _registerCoreAdapters(getIt);
  // register[X]ModuleDependencies(getIt) calls are added with each module.
}

/// The only place that knows which adapter backs each core port. Adapter
/// packages never touch get_it; swapping a technology changes one line here.
void _registerCoreAdapters(GetIt getIt) {
  getIt
    ..registerLazySingleton<AppLogger>(CrashlyticsAppLogger.new)
    ..registerLazySingleton<ApiClient>(
      () => DioApiClient(
        baseUrl: _apiBaseUrl,
        // Null until an authentication module registers a TokenProvider.
        tokenProvider: () =>
            getIt.isRegistered<TokenProvider>() ? getIt<TokenProvider>() : null,
        logger: getIt<AppLogger>(),
      ),
    )
    ..registerLazySingleton<LocalDatabaseFactory>(
      SqlcipherLocalDatabaseFactory.new,
    )
    ..registerLazySingleton<AppPreferences>(
      SharedPreferencesAppPreferences.new,
    )
    ..registerLazySingleton<SyncScheduler>(
      () => WorkmanagerSyncScheduler(callbackDispatcher: outboxSyncDispatcher),
    )
    ..registerLazySingleton<LogoutCleanerRegistry>(
      DefaultLogoutCleanerRegistry.new,
    )
    ..registerLazySingleton<NetworkInterfaceMonitor>(
      ConnectivityPlusNetworkInterfaceMonitor.new,
    )
    ..registerLazySingleton<ReachabilityProbe>(
      () => DioReachabilityProbe(baseUrl: _apiBaseUrl, path: _healthCheckPath),
    )
    ..registerLazySingleton<ConnectivityService>(
      () => DefaultConnectivityService(
        networkInterfaceMonitor: getIt<NetworkInterfaceMonitor>(),
        reachabilityProbe: getIt<ReachabilityProbe>(),
      ),
    )
    ..registerLazySingleton<OutboxRegistry>(DefaultOutboxRegistry.new)
    ..registerLazySingleton<OutboxSyncWorker>(
      () => OutboxSyncWorker(
        registry: getIt<OutboxRegistry>(),
        logger: getIt<AppLogger>(),
      ),
    )
    ..registerLazySingleton<SyncOrchestrator>(
      () => SyncOrchestrator(
        connectivityService: getIt<ConnectivityService>(),
        outboxSyncWorker: getIt<OutboxSyncWorker>(),
      ),
    );
}
