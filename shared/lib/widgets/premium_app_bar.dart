import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final LinearGradient? gradient;
  final bool centerTitle;
  final double elevation;
  final PreferredSizeWidget? bottom;
  final TextStyle? titleStyle;
  final Color? backgroundColor;
  final bool useGradient;

  const PremiumAppBar({
    super.key,
    this.title,
    this.actions,
    this.onBackPressed,
    this.showBackButton = true,
    this.gradient,
    this.centerTitle = true,
    this.elevation = 0,
    this.bottom,
    this.titleStyle,
    this.backgroundColor,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: titleStyle ??
                  Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
            )
          : null,
      centerTitle: centerTitle,
      elevation: elevation,
      scrolledUnderElevation: 0,
      backgroundColor: useGradient && gradient != null
          ? Colors.transparent
          : backgroundColor ?? Colors.transparent,
      flexibleSpace: useGradient && gradient != null
          ? Container(
              decoration: BoxDecoration(gradient: gradient),
            )
          : null,
      leading: showBackButton
          ? Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onBackPressed ?? () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
      kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  // Premium factory constructors
  factory PremiumAppBar.hero({
    required String title,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
  }) =>
      PremiumAppBar(
        title: title,
        gradient: AppTheme.primaryGradient,
        centerTitle: true,
        actions: actions,
        onBackPressed: onBackPressed,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      );

  factory PremiumAppBar.elevated({
    required String title,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
  }) =>
      PremiumAppBar(
        title: title,
        backgroundColor: AppTheme.primaryBlue,
        elevation: 2,
        actions: actions,
        onBackPressed: onBackPressed,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      );

  factory PremiumAppBar.transparent({
    required String title,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
  }) =>
      PremiumAppBar(
        title: title,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: actions,
        onBackPressed: onBackPressed,
        useGradient: false,
      );
}
