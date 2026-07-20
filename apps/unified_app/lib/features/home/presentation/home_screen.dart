import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/widgets/premium_bike_card.dart';
import 'package:shared/widgets/shimmer_loader.dart';
import 'package:shared/widgets/empty_state_widget.dart';
import 'package:shared/widgets/premium_search_field.dart';
import 'package:shared/widgets/floating_filter_button.dart';
import 'package:shared/widgets/loading_animations.dart';
import 'package:shared/theme/app_theme.dart';
import '../../bikes/providers/bike_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  int _selectedIndex = 0;

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

    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => ref.read(bikesProvider.notifier).loadBikes(),
            child: CustomScrollView(
              slivers: [
                // Premium App Bar with Hero Greeting
                SliverAppBar(
                  expandedHeight: 160,
                  floating: true,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Good Morning,\nExplorer!',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Find your perfect ride today',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Colors.white70,
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
                      padding: const EdgeInsets.only(right: 8, top: 8),
                      child: IconButton(
                        icon: const Icon(Icons.person_outline_rounded,
                            color: Colors.white),
                        onPressed: () => context.push('/profile'),
                      ),
                    ),
                  ],
                ),
                // Premium Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
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
                      onSubmitted: (query) {
                        if (query.isNotEmpty) {
                          ref.read(bikesProvider.notifier).searchBikes(query);
                        }
                      },
                    ),
                  ),
                ),
            if (bikesState.categories.isNotEmpty)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                      child: Text(
                        'Categories',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 48,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: bikesState.categories.length,
                        itemBuilder: (context, index) {
                          final cat = bikesState.categories[index];
                          final isSelected = _selectedIndex == index;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: FilterChip(
                              label: Text(
                                cat.name,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() => _selectedIndex = index);
                                ref.read(bikesProvider.notifier).searchBikes(cat.name);
                              },
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              selectedColor: Theme.of(context).colorScheme.primary,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[700],
                              ),
                              side: BorderSide(
                                color: isSelected 
                                  ? Colors.transparent
                                  : Colors.grey[300]!,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available Bikes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () => context.push('/bikes'),
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
            ),
            _buildBikesList(bikesState),
            const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
          ],
        ),
      ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
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
      ),
    );
  }

  Widget _buildBikesList(BikesState bikesState) {
    if (bikesState.isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => const ShimmerLoader(width: double.infinity, height: double.infinity),
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final bike = bikesState.bikes[index];
            return PremiumBikeCard(
              id: bike.id,
              name: bike.bikeName,
              brand: bike.brand,
              category: bike.category ?? 'Standard',
              price: bike.rentalPrice,
              imageUrl: bike.imageUrl,
              status: bike.availabilityStatus,
              onTap: () => context.push('/bike/${bike.id}'),
            );
          },
          childCount: bikesState.bikes.length,
        ),
      ),
    );
  }
}
