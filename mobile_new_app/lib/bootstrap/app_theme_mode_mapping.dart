import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// core is pure Dart, so the host maps its theme choice to Flutter's.
extension AppThemeModeMapping on AppThemeMode {
  ThemeMode toThemeMode() => switch (this) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      };
}
