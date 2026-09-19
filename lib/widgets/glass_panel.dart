import 'package:flutter/material.dart';
import '../app/theme.dart';

/// A glassmorphism-style container card matching the Laravel `.glass-panel`
/// CSS class.
///
/// Provides a semi-transparent, bordered card with rounded corners.
/// Used across dashboards, forms, and content sections.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppTheme.surfaceGlass,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppTheme.borderGlass),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
