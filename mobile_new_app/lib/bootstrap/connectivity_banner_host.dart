import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Shows design_system's banner below every screen while the backend is
/// not reachable. Placeholder texts until the first module with l10n.
class ConnectivityBannerHost extends StatelessWidget {
  const ConnectivityBannerHost({
    super.key,
    required this.connectivity,
    required this.child,
  });

  final ConnectivityService connectivity;
  final Widget child;

  @override
  Widget build(BuildContext context) => StreamBuilder<ConnectivityStatus>(
        stream: connectivity.statusChanges,
        initialData: connectivity.status,
        builder: (context, snapshot) {
          final status = snapshot.data ?? ConnectivityStatus.unknown;
          final visible = status == ConnectivityStatus.offline ||
              status == ConnectivityStatus.noInternet;
          return Column(
            children: [
              Expanded(
                // The banner takes the bottom inset while it is visible.
                child: MediaQuery.removePadding(
                  context: context,
                  removeBottom: visible,
                  child: child,
                ),
              ),
              AppConnectivityBanner(visible: visible, message: _message(status)),
            ],
          );
        },
      );

  static String _message(ConnectivityStatus status) => switch (status) {
        ConnectivityStatus.noInternet =>
          'No internet connection. Your changes are saved and will sync automatically.',
        _ => "You're offline. Your changes are saved and will sync when you're back online.",
      };
}
