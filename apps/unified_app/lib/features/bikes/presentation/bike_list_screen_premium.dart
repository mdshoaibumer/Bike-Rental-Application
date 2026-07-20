import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/widgets/premium_app_bar.dart';
import 'package:shared/widgets/shimmer_loader.dart';
import 'package:shared/widgets/premium_bike_card.dart';
import 'package:shared/widgets/empty_state_widget.dart';
import 'package:shared/widgets/floating_filter_button.dart';
import 'package:shared/theme/app_theme.dart';
import '../providers/bike_provider.dart';

class BikeListScreenPremium extends ConsumerStatefulWidget {
  const BikeListScreenPremium({super.key});

  @override
  ConsumerState<BikeListScreenPremium> createState() =>
      _BikeListScreenPremiumState();
}

class _BikeListScreenPremiumState extends ConsumerState<BikeListScreenPremium>
    with SingleTickerProviderStateMixin {
  late TabController _categoryController;
  final List<String> categories = [
    'All',
    'Standard',
    'Premium',
    'Electric',
    'Mountain'
  ];
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _categoryController = TabController(length: categories.length, vsync: this);
    Future.microtask(() => ref.read(bikesProvider.notifier).loadBikes());
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bikesProvider);

    return Scaffold(
      appBar: PremiumAppBar.hero(
        title: 'Available Bikes',
        onBackPressed: () => Navigator.of(context).pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Colors.white),
            onPressed: () {
              // Show filter bottom sheet
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: List.generate(
                categories.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(categories[index]),
                    selected: _selectedCategoryIndex == index,
                    onSelected: (selected) {
                      setState(() => _selectedCategoryIndex = index);
                    },
                    backgroundColor: Colors.transparent,
                    selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
                    side: BorderSide(
                      color: _selectedCategoryIndex == index
                          ? AppTheme.primaryBlue
                          : AppTheme.textTertiary,
                      width: 2,
                    ),
                    labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _selectedCategoryIndex == index
                          ? AppTheme.primaryBlue
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Bikes Grid
          Expanded(
            child: _buildBody(state),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BikesState state) {
    if (state.isLoading && state.bikes.isEmpty) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 4,
        itemBuilder: (context, index) => const ShimmerLoader(
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    if (state.error != null && state.bikes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.error ?? 'Failed to load bikes',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(bikesProvider.notifier).loadBikes(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.bikes.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.two_wheeler_rounded,
        title: 'No Bikes Available',
        message: 'Check back later for new arrivals or try a different category.',
        actionLabel: 'Refresh',
        onAction: () => ref.read(bikesProvider.notifier).loadBikes(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(bikesProvider.notifier).loadBikes(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: state.bikes.length,
        itemBuilder: (context, index) {
          final bike = state.bikes[index];
          return PremiumBikeCard(
            id: bike.id ?? '',
            name: bike.name,
            brand: bike.brand ?? '',
            price: bike.pricePerDay.toDouble(),
            imageUrl: bike.image,
            category: bike.category ?? 'Standard',
            status: bike.status ?? 'Available',
            rating: bike.rating?.toDouble(),
            reviewCount: bike.reviewCount,
            onTap: () => context.push('/bikes/${bike.id}'),
          );
        },
      ),
    );
  }
}
