import 'package:flutter/material.dart';

import '../tokens/app_breakpoints.dart';
import '../tokens/app_margins.dart';
import '../tokens/app_spacing.dart';

/// Centered icon + title + optional message, for screens with nothing to
/// show yet. Tokens only; adapts its margin to the window size class.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
  });

  final IconData icon;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final margin = AppMargins.of(AppBreakpoints.widthClassOf(context));

    return Center(
      child: Padding(
        padding: EdgeInsets.all(margin),
        child: Semantics(
          container: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Icon(icon, size: AppSpacing.xxxl, color: colors.primary),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(title, style: text.titleLarge, textAlign: TextAlign.center),
              if (message case final message?) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message,
                  style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
