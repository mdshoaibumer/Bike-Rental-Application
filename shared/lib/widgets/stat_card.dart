import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A premium stat card for displaying metrics with animated counters
class StatCard extends StatefulWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final LinearGradient? gradient;
  final VoidCallback? onTap;
  final bool showTrend;
  final bool trendUp;
  final String? trendPercentage;

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.gradient,
    this.onTap,
    this.showTrend = false,
    this.trendUp = true,
    this.trendPercentage,
  }) : super(key: key);

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveGradient = widget.gradient ?? AppTheme.primaryGradient;

    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: effectiveGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.cardShadow,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.icon != null)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        widget.icon,
                        color: widget.iconColor ?? Colors.white,
                        size: 20,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.value,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              widget.subtitle!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white54,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (widget.showTrend && widget.trendPercentage != null)
                    Container(
                      decoration: BoxDecoration(
                        color: widget.trendUp
                            ? AppTheme.successGreen.withOpacity(0.2)
                            : AppTheme.errorRed.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.trendUp
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            color: widget.trendUp
                                ? AppTheme.successGreen
                                : AppTheme.errorRed,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.trendPercentage!,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: widget.trendUp
                                  ? AppTheme.successGreen
                                  : AppTheme.errorRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
