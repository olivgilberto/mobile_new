import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Host-level placeholder, replaced once the first feature module's routes
/// are aggregated.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: AppEmptyState(
          icon: Icons.widgets_outlined,
          title: 'mobile_new',
          message: 'No feature modules yet.',
        ),
      );
}
