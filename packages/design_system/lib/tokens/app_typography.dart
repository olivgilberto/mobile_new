import 'package:flutter/material.dart';

class AppTypography {
  static const _fontFamily = 'Inter';

  // The font is bundled in this package, so Flutter registers it as
  // 'packages/design_system/Inter': without [package] the family would
  // silently fall back to the system font in the host app.
  static const _package = 'design_system';

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontFamily: _fontFamily, package: _package, fontSize: 57, height: 64/57, fontWeight: FontWeight.w400),
    displayMedium: TextStyle(fontFamily: _fontFamily, package: _package, fontSize: 45, height: 52/45, fontWeight: FontWeight.w400),
    displaySmall: TextStyle(fontFamily: _fontFamily, package: _package, fontSize: 36, height: 44/36, fontWeight: FontWeight.w400),
    headlineLarge: TextStyle(fontFamily: _fontFamily, package: _package, fontSize: 32, height: 40/32, fontWeight: FontWeight.w400),
    headlineMedium: TextStyle(fontFamily: _fontFamily, package: _package, fontSize: 28, height: 36/28, fontWeight: FontWeight.w400),
    headlineSmall: TextStyle(fontFamily: _fontFamily, package: _package, fontSize: 24, height: 32/24, fontWeight: FontWeight.w400),
    titleLarge: TextStyle(fontFamily: _fontFamily, package: _package, fontSize: 22, height: 28/22, fontWeight: FontWeight.w400),
    titleMedium: TextStyle(fontFamily: _fontFamily, package: _package, fontSize: 16, height: 24/16, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(fontFamily: _fontFamily, package: _package, fontSize: 14, height: 20/14, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontFamily: _fontFamily, package: _package, fontSize: 16, height: 24/16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontFamily: _fontFamily, package: _package, fontSize: 14, height: 20/14, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontFamily: _fontFamily, package: _package, fontSize: 12, height: 16/12, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontFamily: _fontFamily, package: _package, fontSize: 14, height: 20/14, fontWeight: FontWeight.w500),
    labelMedium: TextStyle(fontFamily: _fontFamily, package: _package, fontSize: 12, height: 16/12, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(fontFamily: _fontFamily, package: _package, fontSize: 11, height: 16/11, fontWeight: FontWeight.w500),
  );
}
