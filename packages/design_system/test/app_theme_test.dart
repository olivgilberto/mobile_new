import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('both themes carry the semantic colors and the packaged Inter font', () {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      expect(theme.extension<AppSemanticColors>(), isNotNull);
      expect(theme.textTheme.bodyMedium?.fontFamily, 'packages/design_system/Inter');
    }
  });

  testWidgets('AppEmptyState renders title and message in light and dark', (tester) async {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: const Scaffold(
          body: AppEmptyState(icon: Icons.inbox, title: 'Nothing here', message: 'Yet'),
        ),
      ));
      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Yet'), findsOneWidget);
    }
  });
}
