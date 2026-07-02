import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../bikes/providers/bike_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

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
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(bikesProvider.notifier).loadBikes(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search bikes...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(bikesProvider.notifier).loadBikes();
                      },
                    ),
                  ),
                  onSubmitted: (query) {
                    if (query.isNotEmpty) {
                      ref.read(bikesProvider.notifier).searchBikes(query);
                    }
                  },
                ),
              ),
            ),
            // Categories
            if (bikesState.categories.isNotEmpty)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: bikesState.categories.length,
                        itemBuilder: (context, index) {
                          final cat = bikesState.categories[index];
                          return Card(
                            margin: const EdgeInsets.only(right: 12),
                            child: InkWell(
                              onTap: () => ref.read(bikesProvider.notifier).searchBikes(cat.name),
                              child: SizedBox(
                                width: 100,
                                child: Center(
                                  child: Text(cat.name, textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            // Bikes header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Available Bikes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => context.push('/bikes'),
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            if (bikesState.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (bikesState.error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(bikesState.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(bikesProvider.notifier).loadBikes(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (bikesState.bikes.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.motorcycle, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No bikes available', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final bike = bikesState.bikes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.motorcycle)),
                        title: Text(bike.bikeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${bike.brand} • ₹${bike.rentalPrice.toInt()}/day'),
                        trailing: ElevatedButton(
                          onPressed: () => context.push('/bike/${bike.id}'),
                          child: const Text('View'),
                        ),
                      ),
                    );
                  },
                  childCount: bikesState.bikes.length,
                ),
              ),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
