import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/widgets/premium_bike_card.dart';
import 'package:shared/widgets/empty_state_widget.dart';
import 'package:shared/widgets/premium_search_field.dart';
import 'package:shared/widgets/floating_filter_button.dart';
import 'package:shared/widgets/loading_animations.dart';
import 'package:shared/widgets/gradient_card.dart';
import 'package:shared/theme/app_theme.dart';
import '../../bikes/providers/bike_provider.dart';

class HomeScreenEnhanced extends ConsumerStatefulWidget {
  const HomeScreenEnhanced({super.key});

  @override
  ConsumerState<HomeScreenEnhanced> createState() => _HomeScreenEnhancedState();
}

class _HomeScreenEnhancedState extends ConsumerState<HomeScreenEnhanced> {
  final _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(bikesProvider.notifier).loadBikes();
      ref.read(bikesProvider.notifier).loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bikesState = ref.watch(bikesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => ref.read(bikesProvider.notifier).loadBikes(),
            child: CustomScrollView(
              slivers: [
                // Premium Hero Header with Gradient
                SliverAppBar(
                  expandedHeight: 180,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Time-based greeting
                              Text(
                                _getTimeBasedGreeting(),
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      height: 1.2,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Discover your next adventure with premium bikes',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12, top: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.push('/profile'),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.person_outline_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Premium Search Field
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: SlideInAnimation(
                      child: PremiumSearchField(
                        controller: _searchController,
                        hintText: 'Search bikes or brands...',
                        onChanged: (_) => setState(() {}),
                        onClear: () {
                          _searchController.clear();
                          ref.read(bikesProvider.notifier).loadBikes();
                          setState(() {});
                        },
                        onFilterTap: () => context.push('/bikes'),
                        enableVoiceSearch: false,
                      ),
                    ),
                  ),
                ),

                // Featured Promotional Banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: GradientCard(
                      gradient: AppTheme.accentGradient,
                      borderRadius: 20,
                      onTap: () => context.push('/bikes'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Limited Time Offer',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: Colors.white70,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Get 20% off on\nweekly bookings',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.local_offer_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Text(
                              'Tap to explore →',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Premium Category Pills
                if (bikesState.categories.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                          child: Text(
                            'Bike Categories',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 56,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: bikesState.categories.length,
                            itemBuilder: (context, index) {
                              final cat = bikesState.categories[index];
                              final isSelected = _selectedCategoryIndex == index;
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedCategoryIndex = index);
                                    ref.read(bikesProvider.notifier).searchBikes(cat.name);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? AppTheme.primaryGradient
                                          : null,
                                      color: isSelected
                                          ? null
                                          : (isDark
                                              ? const Color(0xFF2A2A2A)
                                              : const Color(0xFFF0F0F0)),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: isSelected
                                          ? AppTheme.cardShadow
                                          : [],
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.two_wheeler_rounded,
                                          color: isSelected
                                              ? Colors.white
                                              : AppTheme.textSecondary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          cat.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                color: isSelected
                                                    ? Colors.white
                                                    : AppTheme.textSecondary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                // Available Bikes Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Featured Bikes',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => context.push('/bikes'),
                          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                          label: const Text('View All'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Premium Bikes Grid
                _buildPremiumBikesList(bikesState),

                const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) context.push('/bookings');
          if (index == 2) context.push('/profile');
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingFilterButton(
        onTap: () => context.push('/bikes'),
        showBadge: false,
      ),
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning!';
    } else if (hour < 17) {
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!';
    }
  }

  Widget _buildPremiumBikesList(BikesState bikesState) {
    if (bikesState.isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => ShimmerEffect(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            childCount: 6,
          ),
        ),
      );
    }

    if (bikesState.error != null) {
      return SliverFillRemaining(
        child: EmptyStateWidget(
          icon: Icons.error_outline_rounded,
          title: 'Oops!',
          message: bikesState.error!,
          actionLabel: 'Try Again',
          onAction: () => ref.read(bikesProvider.notifier).loadBikes(),
        ),
      );
    }

    if (bikesState.bikes.isEmpty) {
      return const SliverFillRemaining(
        child: EmptyStateWidget(
          icon: Icons.search_off_rounded,
          title: 'No bikes found',
          message: 'Try adjusting your search or category filters.',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final bike = bikesState.bikes[index];
            return SlideInAnimation(
              beginOffset: const Offset(0, 0.2),
              child: PremiumBikeCard(
                id: bike.id,
                name: bike.bikeName,
                brand: bike.brand,
                category: bike.category ?? 'Standard',
                price: bike.rentalPrice,
                imageUrl: bike.imageUrl,
                status: bike.availabilityStatus,
                rating: 4.8,
                reviewCount: 234,
                onTap: () => context.push('/bike/${bike.id}'),
              ),
            );
          },
          childCount: bikesState.bikes.length,
        ),
      ),
    );
  }
}
