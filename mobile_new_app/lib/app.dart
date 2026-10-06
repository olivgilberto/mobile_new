import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'bootstrap/app_flavor.dart';
import 'bootstrap/app_router.dart';
import 'bootstrap/connectivity_banner_host.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.flavor,
    required this.themeMode,
    required this.connectivity,
  });

  final AppFlavor flavor;

  /// Saved by the user through core's AppPreferences (system by default).
  final ValueListenable<ThemeMode> themeMode;

  /// Drives the non-blocking connectivity banner below every screen.
  final ConnectivityService connectivity;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: themeMode,
        builder: (_, mode, _) => MaterialApp.router(
          title: 'mobile_new',
          debugShowCheckedModeBanner: flavor == AppFlavor.dev,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          routerConfig: appRouter,
          builder: (_, child) => ConnectivityBannerHost(
            connectivity: connectivity,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      );
}
