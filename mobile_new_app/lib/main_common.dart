import 'dart:async';

import 'package:core/core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'bootstrap/app_flavor.dart';
import 'bootstrap/app_theme_mode_mapping.dart';
import 'bootstrap/dependency_injection.dart';

/// Boot sequence (see docs/architecture.md). Every async step has a timeout
/// and a fallback — the boot never blocks on the network.
Future<void> mainCommon({required AppFlavor flavor}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase. Fallback: keep booting without Crashlytics until
  //    `flutterfire configure` has generated the platform config files.
  final firebaseReady = await _initializeFirebase();

  // 2. App Tracking Transparency (iOS): not needed yet — no Analytics or
  //    IDFA-accessing SDK is integrated.

  // 3. Global error handling.
  _configureErrorHandling(reportToLogger: firebaseReady);

  // 4. Dependency injection.
  await configureDependencies();

  // 5. Local preferences (theme; language once a module with l10n exists).
  //    Fallback: follow the system theme.
  final themeMode = await _readThemeMode(reportToLogger: firebaseReady);

  // Connectivity (interface → backend reachability): never awaited, it may
  // touch the network. `SyncOrchestrator.start()` and
  // `SyncScheduler.schedulePeriodicSync()` are added here together with the
  // first feature module that has an outbox.
  unawaited(getIt<ConnectivityService>().start());

  // 6-8. Remote Config, Force Update and terms re-consent: added together
  //      with their ports.

  // 9. Run.
  runApp(App(
    flavor: flavor,
    themeMode: themeMode,
    connectivity: getIt<ConnectivityService>(),
  ));
  // 10. Deep links and auth redirect: resolved by go_router once an
  //     authentication module exists.
}

/// The user's saved theme, kept up to date when a module saves a new one.
Future<ValueNotifier<ThemeMode>> _readThemeMode({required bool reportToLogger}) async {
  final preferences = getIt<AppPreferences>();
  final themeMode = ValueNotifier(ThemeMode.system);
  try {
    themeMode.value = (await preferences.themeMode()
            .timeout(const Duration(seconds: 2)))
        .toThemeMode();
  } catch (error, stackTrace) {
    if (reportToLogger) {
      getIt<AppLogger>().error('Theme preference not read', error: error, stackTrace: stackTrace);
    } else {
      debugPrint('Theme preference not read: $error');
    }
  }
  preferences.themeModeChanges.listen((mode) => themeMode.value = mode.toThemeMode());
  return themeMode;
}

Future<bool> _initializeFirebase() async {
  try {
    await Firebase.initializeApp().timeout(const Duration(seconds: 5));
    return true;
  } catch (error) {
    debugPrint('Firebase not initialized ($error): run `flutterfire configure`.');
    return false;
  }
}

void _configureErrorHandling({required bool reportToLogger}) {
  void report(String message, Object error, StackTrace? stackTrace) {
    if (reportToLogger) {
      getIt<AppLogger>().error(message, error: error, stackTrace: stackTrace);
    } else {
      debugPrint('$message: $error\n$stackTrace');
    }
  }

  FlutterError.onError = (details) {
    if (kDebugMode) FlutterError.presentError(details);
    report('Flutter error', details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    report('Uncaught error', error, stackTrace);
    return true;
  };
  // Never show a technical/blank screen to the user.
  if (!kDebugMode) ErrorWidget.builder = (_) => const _FriendlyErrorWidget();
}

class _FriendlyErrorWidget extends StatelessWidget {
  const _FriendlyErrorWidget();

  @override
  Widget build(BuildContext context) => const Material(
        child: Center(
          child: Icon(Icons.error_outline, semanticLabel: 'Something went wrong'),
        ),
      );
}
