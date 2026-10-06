import 'package:flutter/material.dart';

class AppShape {
  static const none = 0.0;
  static const extraSmall = 4.0;
  static const small = 8.0;
  static const medium = 12.0;
  static const large = 16.0;
  static const extraLarge = 28.0;
  static const full = 999.0; // pill/circular
}

class AppBorderRadius {
  static final none = BorderRadius.circular(AppShape.none);
  static final extraSmall = BorderRadius.circular(AppShape.extraSmall);
  static final small = BorderRadius.circular(AppShape.small);
  static final medium = BorderRadius.circular(AppShape.medium);
  static final large = BorderRadius.circular(AppShape.large);
  static final extraLarge = BorderRadius.circular(AppShape.extraLarge);
  static final full = BorderRadius.circular(AppShape.full);
}
