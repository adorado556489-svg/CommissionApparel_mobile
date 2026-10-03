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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelColor = isDark ? AppTheme.surfaceGlass : AppTheme.lightSurface;
    final borderColor = isDark ? AppTheme.borderGlass : AppTheme.lightBorder;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0x0D000000), // Black at ~5% opacity
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
