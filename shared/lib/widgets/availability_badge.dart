import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A premium badge widget for displaying availability status
class AvailabilityBadge extends StatelessWidget {
  final String label;
  final AvailabilityStatus status;
  final EdgeInsets padding;
  final double borderRadius;
  final bool animated;

  const AvailabilityBadge({
    Key? key,
    required this.label,
    required this.status,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.borderRadius = 8,
    this.animated = true,
  }) : super(key: key);

  Color _getBackgroundColor(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.available:
        return AppTheme._successGreen.withValues(alpha: 0.15);
      case AvailabilityStatus.booked:
        return AppTheme._warningAmber.withValues(alpha: 0.15);
      case AvailabilityStatus.maintenance:
        return AppTheme._errorRed.withValues(alpha: 0.15);
    }
  }

  Color _getTextColor(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.available:
        return AppTheme._successGreen;
      case AvailabilityStatus.booked:
        return AppTheme._warningAmber;
      case AvailabilityStatus.maintenance:
        return AppTheme._errorRed;
    }
  }

  IconData _getIcon(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.available:
        return Icons.check_circle_rounded;
      case AvailabilityStatus.booked:
        return Icons.schedule_rounded;
      case AvailabilityStatus.maintenance:
        return Icons.warning_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor(status);
    final textColor = _getTextColor(status);
    final icon = _getIcon(status);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: textColor,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

enum AvailabilityStatus {
  available,
  booked,
  maintenance,
}
