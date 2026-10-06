import 'dart:async';

import 'package:core/core.dart';
import 'package:test/test.dart';

class _FakeInterfaceMonitor implements NetworkInterfaceMonitor {
  var hasInterface = true;
  final changes = StreamController<bool>.broadcast();

  @override
  Future<bool> hasNetworkInterface() async => hasInterface;

  @override
  Stream<bool> get networkInterfaceChanges => changes.stream;
}

class _FakeProbe implements ReachabilityProbe {
  var reachable = true;
  var calls = 0;

  @override
  Future<bool> isBackendReachable() async {
    calls++;
    return reachable;
  }
}

class _NoopLogger implements AppLogger {
  @override
  void info(String message) {}

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}
}

class _CountingOutbox implements SyncableOutbox {
  var calls = 0;
  Completer<bool> pending = Completer<bool>();

  @override
  String get name => 'counting';

  @override
  Future<bool> syncPending() {
    calls++;
    return pending.future;
  }
}

void main() {
  late _FakeInterfaceMonitor monitor;
  late _FakeProbe probe;
  late DefaultConnectivityService connectivity;

  setUp(() {
    monitor = _FakeInterfaceMonitor();
    probe = _FakeProbe();
    connectivity = DefaultConnectivityService(
      networkInterfaceMonitor: monitor,
      reachabilityProbe: probe,
      minRecheckDelay: const Duration(milliseconds: 10),
    );
  });

  tearDown(() => connectivity.dispose());

  group('DefaultConnectivityService', () {
    test('no interface: offline, and the probe is never called', () async {
      monitor.hasInterface = false;

      expect(await connectivity.check(), ConnectivityStatus.offline);
      expect(probe.calls, 0);
    });

    test('interface but backend silent: noInternet, rechecked until it answers', () async {
      probe.reachable = false;
      expect(await connectivity.check(), ConnectivityStatus.noInternet);

      probe.reachable = true;
      await expectLater(connectivity.statusChanges, emits(ConnectivityStatus.online));
    });

    test('an interface change triggers a new check', () async {
      monitor.hasInterface = false;
      await connectivity.start();
      expect(connectivity.status, ConnectivityStatus.offline);

      monitor.hasInterface = true;
      monitor.changes.add(true);

      await expectLater(connectivity.statusChanges, emits(ConnectivityStatus.online));
    });
  });

  group('SyncOrchestrator', () {
    late _CountingOutbox outbox;
    late SyncOrchestrator orchestrator;

    setUp(() {
      outbox = _CountingOutbox();
      final registry = DefaultOutboxRegistry()..register(outbox);
      orchestrator = SyncOrchestrator(
        connectivityService: connectivity,
        outboxSyncWorker: OutboxSyncWorker(registry: registry, logger: _NoopLogger()),
        debounce: const Duration(milliseconds: 10),
      );
    });

    tearDown(() => orchestrator.dispose());

    test('syncs on the transition to online', () async {
      monitor.hasInterface = false;
      await connectivity.start();
      orchestrator.start();
      expect(outbox.calls, 0);

      monitor.hasInterface = true;
      await connectivity.check();
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(outbox.calls, 1);
      outbox.pending.complete(true);
    });

    test('joins the run in progress instead of starting a second one', () async {
      final first = orchestrator.syncNow();
      final second = orchestrator.syncNow();
      outbox.pending.complete(true);

      expect(await first, isTrue);
      expect(await second, isTrue);
      expect(outbox.calls, 1);
    });
  });
}
