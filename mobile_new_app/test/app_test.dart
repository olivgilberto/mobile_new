import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_new_app/app.dart';
import 'package:mobile_new_app/bootstrap/app_flavor.dart';

class _FakeConnectivity implements ConnectivityService {
  final _changes = StreamController<ConnectivityStatus>.broadcast();

  @override
  var status = ConnectivityStatus.unknown;

  void emit(ConnectivityStatus next) {
    status = next;
    _changes.add(next);
  }

  @override
  Stream<ConnectivityStatus> get statusChanges => _changes.stream;

  @override
  Future<void> start() async {}

  @override
  Future<ConnectivityStatus> check() async => status;

  @override
  Future<void> dispose() => _changes.close();
}

Widget _app({ValueNotifier<ThemeMode>? themeMode, ConnectivityService? connectivity}) => App(
      flavor: AppFlavor.dev,
      themeMode: themeMode ?? ValueNotifier(ThemeMode.system),
      connectivity: connectivity ?? _FakeConnectivity(),
    );

void main() {
  testWidgets('boots into the host placeholder home', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('No feature modules yet.'), findsOneWidget);
  });

  testWidgets('applies a theme change without restarting', (tester) async {
    final themeMode = ValueNotifier(ThemeMode.light);
    await tester.pumpWidget(_app(themeMode: themeMode));
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.byType(Scaffold))).brightness, Brightness.light);

    themeMode.value = ThemeMode.dark;
    await tester.pumpAndSettle();

    expect(Theme.of(tester.element(find.byType(Scaffold))).brightness, Brightness.dark);
  });

  testWidgets('shows the banner only while offline or without internet', (tester) async {
    final connectivity = _FakeConnectivity();
    await tester.pumpWidget(_app(connectivity: connectivity));
    await tester.pumpAndSettle();
    expect(find.textContaining("You're offline"), findsNothing); // unknown at boot

    connectivity.emit(ConnectivityStatus.offline);
    await tester.pumpAndSettle();
    expect(find.textContaining("You're offline"), findsOneWidget);

    connectivity.emit(ConnectivityStatus.noInternet);
    await tester.pumpAndSettle();
    expect(find.textContaining('No internet connection'), findsOneWidget);

    connectivity.emit(ConnectivityStatus.online);
    await tester.pumpAndSettle();
    expect(find.textContaining('No internet connection'), findsNothing);
  });
}
