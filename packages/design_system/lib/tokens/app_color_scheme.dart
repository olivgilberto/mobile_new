import 'package:flutter/material.dart';

class AppColorScheme {
  // Current project seed color — change only this value once the final
  // brand palette is defined; everything else is recalculated
  // automatically.
  static const _brandSeed = Color(0xFF2F6EEA);

  static final light = ColorScheme.fromSeed(
    seedColor: _brandSeed,
    brightness: Brightness.light,
    contrastLevel: 0.5,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  );

  static final dark = ColorScheme.fromSeed(
    seedColor: _brandSeed,
    brightness: Brightness.dark,
    contrastLevel: 0.5,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  );
}
