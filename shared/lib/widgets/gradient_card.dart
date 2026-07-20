import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A premium card widget with gradient overlay and optional glass morphism effect
class GradientCard extends StatelessWidget {
  final Widget child;
  final LinearGradient? gradient;
  final double borderRadius;
  final List<BoxShadow>? shadows;
  final EdgeInsets padding;
  final double opacity;
  final VoidCallback? onTap;
  final bool enableGlassMorphism;

  const GradientCard({
    Key? key,
    required this.child,
    this.gradient,
    this.borderRadius = 24,
    this.shadows,
    this.padding = const EdgeInsets.all(20),
    this.opacity = 1.0,
    this.onTap,
    this.enableGlassMorphism = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveGradient = gradient ?? AppTheme.primaryGradient;
    final effectiveShadows = shadows ?? AppTheme.cardShadow;

    Widget card = Container(
      decoration: BoxDecoration(
        gradient: enableGlassMorphism ? null : effectiveGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: effectiveShadows,
        color: enableGlassMorphism ? null : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: enableGlassMorphism
            ? BackdropFilter(
                filter: const ColorFilter.mode(
                  Color(0x1A000000),
                  BlendMode.darken,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.glassGradient(isDark).scale(opacity),
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.2)
                          : Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Padding(
                    padding: padding,
                    child: child,
                  ),
                ),
              )
            : Padding(
                padding: padding,
                child: child,
              ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}
