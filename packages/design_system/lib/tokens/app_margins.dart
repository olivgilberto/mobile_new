import 'app_breakpoints.dart';

class AppMargins {
  static const compact = 16.0; // WindowWidthClass.compact (smartphone portrait)
  static const wide = 24.0;    // medium and up (tablet, smartphone landscape)

  static double of(WindowWidthClass widthClass) => switch (widthClass) {
        WindowWidthClass.compact => compact,
        WindowWidthClass.medium ||
        WindowWidthClass.expanded ||
        WindowWidthClass.large ||
        WindowWidthClass.extraLarge =>
          wide,
      };
}
