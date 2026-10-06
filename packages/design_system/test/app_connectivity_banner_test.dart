import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host({required bool visible, ThemeData? theme}) => MaterialApp(
      theme: theme ?? AppTheme.light,
      home: Scaffold(
        body: AppConnectivityBanner(visible: visible, message: 'You are offline.'),
      ),
    );

void main() {
  testWidgets('shows the message only when visible, in light and dark', (tester) async {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      await tester.pumpWidget(_host(visible: true, theme: theme));
      await tester.pumpAndSettle();
      expect(find.text('You are offline.'), findsOneWidget);
    }

    await tester.pumpWidget(_host(visible: false));
    await tester.pumpAndSettle();
    expect(find.text('You are offline.'), findsNothing);
  });

  testWidgets('meets the 48dp minimum height', (tester) async {
    await tester.pumpWidget(_host(visible: true));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(Material).last).height, greaterThanOrEqualTo(48));
  });
}
