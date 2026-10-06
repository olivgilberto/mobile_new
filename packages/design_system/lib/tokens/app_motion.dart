import 'package:flutter/material.dart';

class AppMotionDuration {
  static const short1 = Duration(milliseconds: 50);
  static const short2 = Duration(milliseconds: 100);
  static const short3 = Duration(milliseconds: 150);
  static const short4 = Duration(milliseconds: 200);
  static const medium1 = Duration(milliseconds: 250);
  static const medium2 = Duration(milliseconds: 300);
  static const medium3 = Duration(milliseconds: 350);
  static const medium4 = Duration(milliseconds: 400);
  static const long1 = Duration(milliseconds: 450);
  static const long2 = Duration(milliseconds: 500);
  static const long3 = Duration(milliseconds: 550);
  static const long4 = Duration(milliseconds: 600);
  static const extraLong1 = Duration(milliseconds: 700);
  static const extraLong4 = Duration(milliseconds: 1000);
}

/// Re-exposes the official M3 curves that Flutter already provides, instead
/// of redeclaring their values. `emphasized` is not a simple cubic in M3 —
/// it is a two-segment curve (`ThreePointCubic`).
class AppMotionCurve {
  static const Curve standard = Easing.standard;
  static const Curve standardAccelerate = Easing.standardAccelerate;
  static const Curve standardDecelerate = Easing.standardDecelerate;
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
  static const Curve emphasizedAccelerate = Easing.emphasizedAccelerate;
  static const Curve emphasizedDecelerate = Easing.emphasizedDecelerate;
}

class AppMotionHelper {
  /// Always use this function instead of the raw Duration — it drastically
  /// shortens the animation if the user has "reduce motion" enabled in the
  /// operating system (accessibility).
  static Duration resolve(BuildContext context, Duration duration) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    return disableAnimations ? const Duration(milliseconds: 1) : duration;
  }
}
