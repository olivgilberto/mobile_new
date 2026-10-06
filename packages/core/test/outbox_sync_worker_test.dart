import 'package:core/core.dart';
import 'package:test/test.dart';

class _FakeOutbox implements SyncableOutbox {
  _FakeOutbox(this.name, this._sync);

  @override
  final String name;
  final Future<bool> Function() _sync;
  var calls = 0;

  @override
  Future<bool> syncPending() {
    calls++;
    return _sync();
  }
}

class _RecordingLogger implements AppLogger {
  final errors = <String>[];

  @override
  void info(String message) {}

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) => errors.add(message);
}

void main() {
  late _RecordingLogger logger;
  late DefaultOutboxRegistry registry;

  setUp(() {
    logger = _RecordingLogger();
    registry = DefaultOutboxRegistry();
  });

  OutboxSyncWorker worker() => OutboxSyncWorker(registry: registry, logger: logger);

  test('nothing registered: done, nothing to retry', () async {
    expect(await worker().run(), isTrue);
  });

  test('true only when every outbox is fully synced', () async {
    registry
      ..register(_FakeOutbox('a', () async => true))
      ..register(_FakeOutbox('b', () async => false));

    expect(await worker().run(), isFalse);
  });

  test('one module failing never stops the others, and is logged by name', () async {
    final failing = _FakeOutbox('broken_module', () async => throw StateError('boom'));
    final healthy = _FakeOutbox('item_module', () async => true);
    registry
      ..register(failing)
      ..register(healthy);

    expect(await worker().run(), isFalse);
    expect(healthy.calls, 1);
    expect(logger.errors, ['Outbox sync failed: broken_module']);
  });
}
