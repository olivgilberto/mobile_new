import 'package:adapter_logging_crashlytics/adapter_logging_crashlytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  late _MockCrashlytics crashlytics;
  late CrashlyticsAppLogger logger;

  setUp(() {
    crashlytics = _MockCrashlytics();
    when(() => crashlytics.log(any())).thenAnswer((_) async {});
    when(() => crashlytics.recordError(any(), any(), reason: any(named: 'reason')))
        .thenAnswer((_) async {});
    logger = CrashlyticsAppLogger(crashlytics: crashlytics);
  });

  test('info becomes a Crashlytics breadcrumb', () {
    logger.info('opened home');
    verify(() => crashlytics.log('opened home')).called(1);
  });

  test('error becomes a non-fatal report with the message as reason', () {
    final error = StateError('boom');
    final stackTrace = StackTrace.current;

    logger.error('sync failed', error: error, stackTrace: stackTrace);

    verify(() => crashlytics.recordError(error, stackTrace, reason: 'sync failed')).called(1);
  });

  test('error without an exception still reports the message', () {
    logger.error('unexpected state');
    verify(() => crashlytics.recordError('unexpected state', any(), reason: 'unexpected state'))
        .called(1);
  });
}
