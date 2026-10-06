import 'package:adapter_connectivity_connectivity_plus/adapter_connectivity_connectivity_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockConnectivity extends Mock implements Connectivity {}

void main() {
  late _MockConnectivity connectivity;
  late ConnectivityPlusNetworkInterfaceMonitor monitor;

  setUp(() {
    connectivity = _MockConnectivity();
    monitor = ConnectivityPlusNetworkInterfaceMonitor(connectivity: connectivity);
  });

  test('any interface other than none counts', () async {
    when(() => connectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.none, ConnectivityResult.wifi]);
    expect(await monitor.hasNetworkInterface(), isTrue);

    when(() => connectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.none]);
    expect(await monitor.hasNetworkInterface(), isFalse);
  });

  test('a plugin failure assumes an interface (the probe decides)', () async {
    when(() => connectivity.checkConnectivity()).thenThrow(PlatformException(code: 'x'));
    expect(await monitor.hasNetworkInterface(), isTrue);
  });

  test('changes are mapped to booleans and deduplicated', () async {
    when(() => connectivity.onConnectivityChanged).thenAnswer((_) => Stream.fromIterable([
          [ConnectivityResult.wifi],
          [ConnectivityResult.mobile],
          [ConnectivityResult.none],
        ]));
    expect(await monitor.networkInterfaceChanges.toList(), [true, false]);
  });
}
