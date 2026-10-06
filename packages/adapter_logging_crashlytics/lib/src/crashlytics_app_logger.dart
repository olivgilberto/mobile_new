import 'dart:async';

import 'package:core/core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Sends `info` as Crashlytics breadcrumbs and `error` as non-fatal
/// reports; also echoes to the console in debug builds. Requires
/// `Firebase.initializeApp()` before first use (boot step 1).
class CrashlyticsAppLogger implements AppLogger {
  CrashlyticsAppLogger({FirebaseCrashlytics? crashlytics})
      : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  final FirebaseCrashlytics _crashlytics;

  @override
  void info(String message) {
    if (kDebugMode) debugPrint('[info] $message');
    unawaited(_crashlytics.log(message));
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) debugPrint('[error] $message ${error ?? ''}');
    unawaited(
      _crashlytics.recordError(
        error ?? message,
        stackTrace ?? StackTrace.current,
        reason: message,
      ),
    );
  }
}
