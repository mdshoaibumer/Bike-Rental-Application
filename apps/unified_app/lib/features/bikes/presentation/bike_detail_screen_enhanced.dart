import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/widgets/gradient_card.dart';
import 'package:shared/widgets/premium_rating_display.dart';
import 'package:shared/widgets/availability_badge.dart';
import 'package:shared/widgets/price_breakdown.dart';
import 'package:shared/widgets/loading_animations.dart';
import 'package:shared/theme/app_theme.dart';
import '../providers/bike_provider.dart';
import '../../booking/providers/booking_provider.dart';

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
  late AnimationController _floatingButtonController;
  DateTime? _pickupDate;
  DateTime? _returnDate;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _floatingButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _floatingButtonController.forward();
  }

  @override
  void dispose() {
    _floatingButtonController.dispose();
    super.dispose();
  }

  AvailabilityStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AvailabilityStatus.available;
      case 'on rent':
        return AvailabilityStatus.booked;
      case 'maintenance':
        return AvailabilityStatus.maintenance;
      default:
        return AvailabilityStatus.available;
    }
  }

  Future<void> _selectPickupDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date != null) {
      setState(() {
        _pickupDate = date;
        if (_returnDate != null && _returnDate!.isBefore(date)) {
          _returnDate = null;
        }
      });
    }
  }

  Future<void> _selectReturnDate() async {
    final firstDate = _pickupDate?.add(const Duration(days: 1)) ??
        DateTime.now().add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 120)),
    );
    if (date != null) {
      setState(() => _returnDate = date);
    }
  }

  int get _durationDays {
    if (_pickupDate != null && _returnDate != null) {
      return _returnDate!.difference(_pickupDate!).inDays;
    }
    return 1;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _handleBooking(Bike bike) async {
    if (_pickupDate == null || _returnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Please select pickup and return dates'),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isBooking = true);
    final success = await ref.read(bookingsProvider.notifier).createBooking(
      bike.id,
      _pickupDate!,
      _returnDate!,
    );
    setState(() => _isBooking = false);

    if (mounted) {
      if (success) {
        _showBookingSuccess(bike);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showBookingSuccess(Bike bike) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.successGreen,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Booking Confirmed!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${bike.bikeName} has been booked for $_durationDays days',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.go('/bookings');
                    },
                    child: const Text('View Bookings'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.go('/home');
                    },
                    child: const Text('Go Home'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bikeAsync = ref.watch(bikeDetailProvider(widget.bikeId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return bikeAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: PremiumLoadingSpinner(color: AppTheme.primaryBlue),
        ),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.errorRed),
              const SizedBox(height: 16),
              Text('Failed to load bike details',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.invalidate(bikeDetailProvider(widget.bikeId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (bike) {
        if (bike == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Bike not found')),
          );
        }
        return _buildBikeDetail(context, bike, isDark);
      },
    );
  }

  Widget _buildBikeDetail(BuildContext context, Bike bike, bool isDark) {
    final isAvailable = bike.availabilityStatus.toLowerCase() == 'available';
    final dailyRate = bike.rentalPrice;
    final totalRent = dailyRate * _durationDays;
    final taxes = totalRent * 0.18;
    final deposit = bike.securityDeposit;

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
                  // Image with Hero animation
                  Hero(
                    tag: 'bike_img_${bike.id}',
                    child: bike.imageUrl != null
                        ? (bike.imageUrl!.startsWith('assets/')
                            ? Image.asset(
                                bike.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildFallbackImage(isDark),
                              )
                            : Image.network(
                                bike.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildFallbackImage(isDark),
                              ))
                        : _buildFallbackImage(isDark),
                  ),
                  // Gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Status Badge
                  Positioned(
                    top: 60,
                    left: 20,
                    child: SafeArea(
                      child: AvailabilityBadge(
                        label: bike.availabilityStatus,
                        status: _mapStatus(bike.availabilityStatus),
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
                          color: Colors.white.withOpacity(0.95),
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.cardShadow,
                        ),
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.favorite_outline,
                          color: AppTheme.textSecondary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  // Price overlay at bottom
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '₹${bike.rentalPrice.toInt()}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'per day',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
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
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.cardShadow,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.textPrimary,
                  size: 20,
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
                    bike.bikeName,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (bike.brand.isNotEmpty) ...[
                        const Icon(Icons.two_wheeler_rounded,
                            size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${bike.brand} • ${bike.engineCC}cc',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                      if (bike.category != null) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            bike.category!,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Rating & Reviews
                  const PremiumRatingDisplay(
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
                    childAspectRatio: 2.2,
                    children: [
                      _buildSpecCard(context, 'Engine', '${bike.engineCC}cc'),
                      _buildSpecCard(context, 'Fuel Type', bike.fuelType),
                      _buildSpecCard(context, 'Transmission', bike.transmission),
                      _buildSpecCard(context, 'Mileage', '35 km/l'),
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
                      _buildFeatureChip(context, 'Insurance', Icons.security_rounded),
                      _buildFeatureChip(context, 'Helmet', Icons.sports_motorsports_rounded),
                      _buildFeatureChip(context, 'GPS', Icons.location_on_rounded),
                      _buildFeatureChip(context, '24/7 Support', Icons.support_agent_rounded),
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
                          gradient: _pickupDate != null
                              ? AppTheme.primaryGradient
                              : null,
                          onTap: isAvailable ? _selectPickupDate : null,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded,
                                      size: 14,
                                      color: _pickupDate != null
                                          ? Colors.white70
                                          : AppTheme.textSecondary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Pickup',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: _pickupDate != null
                                              ? Colors.white70
                                              : AppTheme.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatDate(_pickupDate),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: _pickupDate != null
                                          ? Colors.white
                                          : AppTheme.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GradientCard(
                          padding: const EdgeInsets.all(16),
                          gradient: _returnDate != null
                              ? AppTheme.primaryGradient
                              : null,
                          onTap: isAvailable ? _selectReturnDate : null,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.event_available_rounded,
                                      size: 14,
                                      color: _returnDate != null
                                          ? Colors.white70
                                          : AppTheme.textSecondary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Return',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: _returnDate != null
                                              ? Colors.white70
                                              : AppTheme.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatDate(_returnDate),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: _returnDate != null
                                          ? Colors.white
                                          : AppTheme.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_pickupDate != null && _returnDate != null) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        '$_durationDays day${_durationDays > 1 ? 's' : ''} rental',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Price Breakdown
                  PriceBreakdown(
                    currencySymbol: '₹',
                    items: [
                      PriceItem(
                          label: 'Daily Rate × $_durationDays day${_durationDays > 1 ? 's' : ''}',
                          amount: totalRent),
                      PriceItem(label: 'Security Deposit (refundable)', amount: deposit),
                      PriceItem(label: 'GST (18%)', amount: taxes),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      // Sticky Booking Button
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: _floatingButtonController,
                curve: Curves.easeOutBack,
              ),
            ),
            child: ElevatedButton(
              onPressed: isAvailable && !_isBooking
                  ? () => _handleBooking(bike)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAvailable ? AppTheme.primaryBlue : Colors.grey,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: _isBooking
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isAvailable
                            ? Icons.check_circle_outline_rounded
                            : Icons.block_rounded),
                        const SizedBox(width: 12),
                        Text(
                          isAvailable ? 'Book Now' : 'Not Available',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackImage(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.two_wheeler_rounded,
          size: 64,
          color: isDark ? Colors.white24 : Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildSpecCard(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
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
        color: AppTheme.primaryBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.15),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
