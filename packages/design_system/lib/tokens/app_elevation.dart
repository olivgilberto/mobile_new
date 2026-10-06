import 'package:flutter/material.dart';

class AppElevation {
  static const level0 = <BoxShadow>[]; // No shadow (surface on the base plane)
  static const level1 = <BoxShadow>[
    BoxShadow(color: Color(0x21000000), offset: Offset(0, 0), blurRadius: 2),
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 4),
  ];
  static const level2 = <BoxShadow>[ // Cards
    BoxShadow(color: Color(0x21000000), offset: Offset(0, 0), blurRadius: 2),
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 2), blurRadius: 8),
  ];
  static const level3 = <BoxShadow>[ // Toast, menus
    BoxShadow(color: Color(0x21000000), offset: Offset(0, 0), blurRadius: 2),
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 8), blurRadius: 16),
  ];
  static const level4 = <BoxShadow>[ // Popover, highlighted element
    BoxShadow(color: Color(0x21000000), offset: Offset(0, 0), blurRadius: 2),
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 14), blurRadius: 28),
  ];
}

class AppScrim {
  static const color = Color(0x8A000000);
}
