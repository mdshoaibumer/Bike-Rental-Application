import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/widgets/premium_bike_card.dart';
import 'package:shared/widgets/shimmer_loader.dart';
import 'package:shared/widgets/empty_state_widget.dart';
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
      body: RefreshIndicator(
        onRefresh: () => ref.read(bikesProvider.notifier).loadBikes(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              title: Text(
                'Explore Bikes',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).appBarTheme.iconTheme?.color,
                    ),
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_outline_rounded),
                  onPressed: () => context.push('/profile'),
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for bikes or brands...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(bikesProvider.notifier).loadBikes();
                              setState(() {});
                            },
                          )
                        : null,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                  ),
                  onChanged: (_) => setState(() {}),
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
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                      child: Text(
                        'Categories',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    SizedBox(
                      height: 44,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: bikesState.categories.length,
                        itemBuilder: (context, index) {
                          final cat = bikesState.categories[index];
                          final isSelected = _selectedIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ChoiceChip(
                              label: Text(cat.name),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() => _selectedIndex = index);
                                ref.read(bikesProvider.notifier).searchBikes(cat.name);
                              },
                              labelStyle: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.white : null,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              showCheckmark: false,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) context.push('/bookings');
          if (index == 2) context.push('/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBikesList(BikesState bikesState) {
    if (bikesState.isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => const ShimmerLoader(width: double.infinity, height: double.infinity),
            childCount: 4,
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
