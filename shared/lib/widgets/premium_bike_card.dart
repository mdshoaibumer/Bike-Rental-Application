import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumBikeCard extends StatefulWidget {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String? imageUrl;
  final String category;
  final String status;
  final VoidCallback onTap;
  final double? rating;
  final int? reviewCount;
  final bool? isFavorite;
  final ValueChanged<bool>? onFavoriteChanged;

  const PremiumBikeCard({
    super.key,
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    this.imageUrl,
    this.category = 'Standard',
    this.status = 'Available',
    required this.onTap,
    this.rating,
    this.reviewCount,
    this.isFavorite = false,
    this.onFavoriteChanged,
  });

  @override
  State<PremiumBikeCard> createState() => _PremiumBikeCardState();
}

class _PremiumBikeCardState extends State<PremiumBikeCard>
    with SingleTickerProviderStateMixin {
  bool _isFavorite = false;
  late AnimationController _favoriteAnimationController;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite ?? false;
    _favoriteAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(PremiumBikeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _isFavorite = widget.isFavorite ?? false;
    }
  }

  @override
  void dispose() {
    _favoriteAnimationController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
      if (_isFavorite) {
        _favoriteAnimationController.forward();
      } else {
        _favoriteAnimationController.reverse();
      }
    });
    widget.onFavoriteChanged?.call(_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAvailable = widget.status.toLowerCase() == 'available';

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Gradient Overlay
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child: widget.imageUrl != null
                      ? Hero(
                          tag: 'bike_img_${widget.id}',
                          child: widget.imageUrl!.startsWith('assets/')
                              ? Image.asset(
                                  widget.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const _FallbackImage(),
                                )
                              : Image.network(
                                  widget.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const _FallbackImage(),
                                ),
                        )
                      : Hero(
                          tag: 'bike_img_${widget.id}',
                          child: const _FallbackImage(),
                        ),
                  ),
                  // Premium gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Status Badge
                  if (widget.status.isNotEmpty)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? AppTheme.successGreen.withOpacity(0.95)
                              : AppTheme.warningAmber.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAvailable ? Icons.check_circle : Icons.schedule,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.status,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Favorite Button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: _toggleFavorite,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 1.0, end: 1.2).animate(
                          CurvedAnimation(
                            parent: _favoriteAnimationController,
                            curve: Curves.elasticOut,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.cardShadow,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_outline,
                            color:
                                _isFavorite ? AppTheme.errorRed : AppTheme.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Price Tag
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black87.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '₹${widget.price.toInt()}',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'per day',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details Section
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Brand
                  Text(
                    widget.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.two_wheeler_rounded,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.brand,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          widget.category,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.rating != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppTheme.accentOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.rating!.toStringAsFixed(1)} (${widget.reviewCount ?? 0})',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallbackImage extends StatelessWidget {
  const _FallbackImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: const Center(
        child: Icon(Icons.motorcycle, size: 48, color: Colors.grey),
      ),
    );
  }
}
