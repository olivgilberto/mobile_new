import 'package:adapter_sync_workmanager/adapter_sync_workmanager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:workmanager/workmanager.dart';

class _MockWorkmanager extends Mock implements Workmanager {}

void _dispatcher() {}

void main() {
  setUpAll(() {
    registerFallbackValue(Constraints());
    registerFallbackValue(ExistingPeriodicWorkPolicy.keep);
  });

  test('initializes with the host dispatcher and registers a network-bound periodic task',
      () async {
    final workmanager = _MockWorkmanager();
    when(() => workmanager.initialize(any())).thenAnswer((_) async {});
    when(() => workmanager.registerPeriodicTask(
          any(),
          any(),
          frequency: any(named: 'frequency'),
          constraints: any(named: 'constraints'),
          existingWorkPolicy: any(named: 'existingWorkPolicy'),
        )).thenAnswer((_) async {});

    await WorkmanagerSyncScheduler(
      callbackDispatcher: _dispatcher,
      frequency: const Duration(hours: 2),
      workmanager: workmanager,
    ).schedulePeriodicSync();

    verify(() => workmanager.initialize(_dispatcher)).called(1);
    final captured = verify(() => workmanager.registerPeriodicTask(
          WorkmanagerSyncScheduler.taskName,
          WorkmanagerSyncScheduler.taskName,
          frequency: const Duration(hours: 2),
          constraints: captureAny(named: 'constraints'),
          existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
        )).captured;
    expect((captured.single as Constraints).networkType, NetworkType.connected);
  });
}
