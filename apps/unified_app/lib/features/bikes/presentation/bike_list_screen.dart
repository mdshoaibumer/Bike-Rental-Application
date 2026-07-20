import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/widgets/shimmer_loader.dart';
import 'package:shared/widgets/premium_bike_card.dart';
import 'package:shared/widgets/empty_state_widget.dart';
import '../providers/bike_provider.dart';

class BikeListScreen extends ConsumerStatefulWidget {
  const BikeListScreen({super.key});

  @override
  ConsumerState<BikeListScreen> createState() => _BikeListScreenState();
}

class _BikeListScreenState extends ConsumerState<BikeListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(bikesProvider.notifier).loadBikes());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bikesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Bikes'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 8,
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(BikesState state) {
    if (state.isLoading && state.bikes.isEmpty) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const ShimmerLoader(width: double.infinity, height: double.infinity),
      );
    }
    if (state.error != null && state.bikes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(bikesProvider.notifier).loadBikes(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (state.bikes.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.two_wheeler_rounded,
        title: 'No bikes available',
        message: 'Check back later for new arrivals.',
        actionLabel: 'Refresh',
        onAction: () => ref.read(bikesProvider.notifier).loadBikes(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(bikesProvider.notifier).loadBikes(),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: state.bikes.length,
        itemBuilder: (context, index) {
          final bike = state.bikes[index];
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
      ),
    );
  }
}
