import 'package:flutter/material.dart';

enum WindowWidthClass { compact, medium, expanded, large, extraLarge }
enum WindowHeightClass { compact, medium, expanded }

class AppBreakpoints {
  static WindowWidthClass widthClassOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return WindowWidthClass.compact;      // smartphone portrait
    if (width < 840) return WindowWidthClass.medium;         // tablet portrait
    if (width < 1200) return WindowWidthClass.expanded;      // tablet landscape
    if (width < 1600) return WindowWidthClass.large;
    return WindowWidthClass.extraLarge;
  }

  static WindowHeightClass heightClassOf(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    if (height < 480) return WindowHeightClass.compact;   // smartphone landscape
    if (height < 900) return WindowHeightClass.medium;
    return WindowHeightClass.expanded;
  }
}
