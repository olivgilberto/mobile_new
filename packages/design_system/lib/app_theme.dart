import 'package:flutter/material.dart';

import 'tokens/app_color_scheme.dart';
import 'tokens/app_semantic_colors.dart';
import 'tokens/app_shape.dart';
import 'tokens/app_typography.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        colorScheme: AppColorScheme.light,
        textTheme: AppTypography.textTheme,
        extensions: [AppSemanticColors.light],
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.medium),
        ),
      );

  static ThemeData get dark => ThemeData(
        colorScheme: AppColorScheme.dark,
        textTheme: AppTypography.textTheme,
        extensions: [AppSemanticColors.dark],
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.medium),
        ),
      );
}
