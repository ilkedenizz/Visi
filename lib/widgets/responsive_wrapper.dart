import 'package:flutter/material.dart';

/// Wraps a child widget with a centered [ConstrainedBox] that limits
/// the maximum width on larger screens while keeping the content full‑width
/// on mobile. Also adds horizontal padding on tablet/desktop for better
/// visual balance.
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Mobile (≤599) – use full width.
        if (width < 600) {
          return child;
        }
        // Tablet (600‑1023) – limit to 720px max, with some horizontal padding.
        if (width < 1024) {
          final max = 720.0;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: max),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: child,
              ),
            ),
          );
        }
        // Desktop (≥1024) – limit to 1200px max, extra horizontal padding.
        final max = 1200.0;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: max),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
