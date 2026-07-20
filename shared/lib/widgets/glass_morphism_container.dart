import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassMorphismContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final LinearGradient? gradient;

  const GlassMorphismContainer({
    super.key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.15,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.backgroundColor,
    this.border,
    this.boxShadow,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: border ??
            Border.all(
              color: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.1),
              width: 1.5,
            ),
        boxShadow: boxShadow ?? AppTheme.elevatedShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient ?? AppTheme.glassGradient(isDark),
              borderRadius: borderRadius,
            ),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  static GlassMorphismContainer premiumCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(24)),
  }) {
    return GlassMorphismContainer(
      padding: padding,
      borderRadius: borderRadius,
      blur: 15,
      opacity: 0.2,
      boxShadow: AppTheme.elevatedShadow,
      child: child,
    );
  }

  static GlassMorphismContainer premium({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(20)),
  }) {
    return GlassMorphismContainer(
      padding: padding,
      borderRadius: borderRadius,
      blur: 12,
      opacity: 0.18,
      child: child,
    );
  }
}
