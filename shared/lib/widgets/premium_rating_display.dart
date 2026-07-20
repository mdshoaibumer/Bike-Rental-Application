import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A premium rating display widget with stars and review count
class PremiumRatingDisplay extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double starSize;
  final bool showCount;
  final TextStyle? textStyle;
  final MainAxisAlignment alignment;

  const PremiumRatingDisplay({
    Key? key,
    required this.rating,
    this.reviewCount = 0,
    this.starSize = 16,
    this.showCount = true,
    this.textStyle,
    this.alignment = MainAxisAlignment.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stars = <Widget>[];
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;

    // Add full stars
    for (int i = 0; i < fullStars; i++) {
      stars.add(
        Icon(
          Icons.star_rounded,
          color: AppTheme._accentOrange,
          size: starSize,
        ),
      );
    }

    // Add half star if needed
    if (hasHalfStar && fullStars < 5) {
      stars.add(
        SizedBox(
          width: starSize,
          height: starSize,
          child: Stack(
            children: [
              Icon(
                Icons.star_outline_rounded,
                color: Colors.grey[300],
                size: starSize,
              ),
              ClipRect(
                clipper: _HalfClipper(),
                child: Icon(
                  Icons.star_rounded,
                  color: AppTheme._accentOrange,
                  size: starSize,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Add empty stars
    while (stars.length < 5) {
      stars.add(
        Icon(
          Icons.star_outline_rounded,
          color: Colors.grey[300],
          size: starSize,
        ),
      );
    }

    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < stars.length; i++) ...[
              stars[i],
              if (i < stars.length - 1) SizedBox(width: starSize * 0.1),
            ],
          ],
        ),
        if (showCount) ...[
          const SizedBox(width: 8),
          Text(
            '${rating.toStringAsFixed(1)} ($reviewCount)',
            style: textStyle ??
                Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme._textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ],
    );
  }
}

class _HalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width / 2, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return false;
  }
}
