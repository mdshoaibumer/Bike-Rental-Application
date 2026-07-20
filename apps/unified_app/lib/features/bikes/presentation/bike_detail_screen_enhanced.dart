import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/widgets/gradient_card.dart';
import 'package:shared/widgets/premium_rating_display.dart';
import 'package:shared/widgets/availability_badge.dart';
import 'package:shared/widgets/price_breakdown.dart';
import 'package:shared/theme/app_theme.dart';
import '../providers/bike_provider.dart';

class BikeDetailScreenEnhanced extends ConsumerStatefulWidget {
  final String bikeId;

  const BikeDetailScreenEnhanced({
    super.key,
    required this.bikeId,
  });

  @override
  ConsumerState<BikeDetailScreenEnhanced> createState() =>
      _BikeDetailScreenEnhancedState();
}

class _BikeDetailScreenEnhancedState extends ConsumerState<BikeDetailScreenEnhanced>
    with SingleTickerProviderStateMixin {
  late PageController _imageController;
  int _currentImageIndex = 0;
  late AnimationController _floatingButtonController;
  bool _showFloatingButton = false;

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
    _floatingButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    Future.microtask(() {
      ref.read(bikesProvider.notifier).getBikeById(widget.bikeId);
    });
  }

  @override
  void dispose() {
    _imageController.dispose();
    _floatingButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bikesState = ref.watch(bikesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Premium Image Gallery
          SliverAppBar(
            expandedHeight: 320,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image Carousel
                  PageView.builder(
                    controller: _imageController,
                    onPageChanged: (index) {
                      setState(() => _currentImageIndex = index);
                    },
                    itemCount: 3, // Placeholder for multiple images
                    itemBuilder: (context, index) {
                      return Container(
                        color: isDark
                            ? const Color(0xFF1E1E1E)
                            : Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.two_wheeler_rounded, size: 64),
                        ),
                      );
                    },
                  ),
                  // Status Badge
                  Positioned(
                    top: 60,
                    left: 20,
                    child: SafeArea(
                      child: AvailabilityBadge(
                        label: 'Available Now',
                        status: AvailabilityStatus.available,
                      ),
                    ),
                  ),
                  // Favorite Button
                  Positioned(
                    top: 60,
                    right: 20,
                    child: SafeArea(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.cardShadow,
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.favorite_outline,
                          color: AppTheme._textSecondary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  // Image Indicators
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Container(
                            width: _currentImageIndex == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index
                                  ? AppTheme._accentOrange
                                  : Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: AppTheme._textPrimary,
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bike Name & Brand
                  Text(
                    'Honda CB350',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Honda • 350cc',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                              color: AppTheme._textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '₹899/day',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme._primaryBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Rating & Reviews
                  PremiumRatingDisplay(
                    rating: 4.8,
                    reviewCount: 234,
                    starSize: 18,
                  ),
                  const SizedBox(height: 24),

                  // Specifications Grid
                  Text(
                    'Specifications',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    children: [
                      _buildSpecCard(context, 'Engine', '350cc'),
                      _buildSpecCard(context, 'Fuel Type', 'Petrol'),
                      _buildSpecCard(context, 'Transmission', 'Manual'),
                      _buildSpecCard(context, 'Mileage', '32 km/l'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Rental Includes
                  Text(
                    'Rental Includes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildFeatureChip(context, 'Insurance', Icons.security),
                      _buildFeatureChip(context, 'Helmet', Icons.shopping_bag),
                      _buildFeatureChip(context, 'GPS', Icons.location_on),
                      _buildFeatureChip(context, '24/7 Support', Icons.support_agent),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Date Picker Section
                  Text(
                    'Select Dates',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GradientCard(
                          padding: const EdgeInsets.all(16),
                          gradient: AppTheme.primaryGradient,
                          onTap: () {},
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pickup',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Select Date',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GradientCard(
                          padding: const EdgeInsets.all(16),
                          gradient: AppTheme.primaryGradient,
                          onTap: () {},
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Return',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Select Date',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Price Breakdown
                  PriceBreakdown(
                    items: [
                      PriceItem(label: 'Daily Rate (2 days)', amount: 1798),
                      PriceItem(label: 'Security Deposit', amount: 2000),
                      PriceItem(label: 'Insurance', amount: 200),
                    ],
                    discountCode: 'SAVE20',
                    discountAmount: 359.6,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      // Sticky Booking Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/booking/checkout'),
        backgroundColor: AppTheme._primaryBlue,
        label: const Text('Book Now'),
        icon: const Icon(Icons.check_circle_outline),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSpecCard(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme._primaryBlue.withValues(alpha: 0.1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme._textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(BuildContext context, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme._primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme._primaryBlue.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme._primaryBlue,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme._primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
