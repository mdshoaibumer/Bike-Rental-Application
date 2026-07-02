import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      appBar: AppBar(title: const Text('All Bikes')),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(BikesState state) {
    if (state.isLoading && state.bikes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
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
      return const Center(child: Text('No bikes available'));
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
          return InkWell(
            onTap: () => context.push('/bike/${bike.id}'),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: bike.imageUrl != null
                        ? Image.network(bike.imageUrl!, fit: BoxFit.cover)
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.motorcycle, size: 48),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bike.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${bike.rentalPrice.toStringAsFixed(0)}/day',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
