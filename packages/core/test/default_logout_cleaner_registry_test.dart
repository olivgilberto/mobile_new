import 'package:core/core.dart';
import 'package:test/test.dart';

class _RecordingCleaner implements ClearableOnLogout {
  _RecordingCleaner(this.name, this.calls);
  final String name;
  final List<String> calls;

  @override
  Future<void> clearLocalData() async => calls.add(name);
}

void main() {
  test('clears every registered cleaner, in registration order', () async {
    final calls = <String>[];
    final registry = DefaultLogoutCleanerRegistry()
      ..register(_RecordingCleaner('a', calls))
      ..register(_RecordingCleaner('b', calls));

    await registry.clearAll();

    expect(calls, ['a', 'b']);
  });
}
