import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/widgets/empty_state_widget.dart';
import 'package:shared/widgets/shimmer_loader.dart';
import '../../../../core/admin_providers.dart';

class BikeManagementScreen extends ConsumerStatefulWidget {
  const BikeManagementScreen({super.key});

  @override
  ConsumerState<BikeManagementScreen> createState() => _BikeManagementScreenState();
}

class _BikeManagementScreenState extends ConsumerState<BikeManagementScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(ownerBikesProvider.notifier).loadBikes());
  }

  void _showAddBikeDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final depositController = TextEditingController();
    final regController = TextEditingController();
    String category = 'Cruiser';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Add New Bike', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Model Name / Brand'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: regController,
                      decoration: const InputDecoration(labelText: 'Registration Number'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: ['Cruiser', 'Sport', 'Scooter', 'Street'].map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => category = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Daily Rental Price (₹)'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: depositController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Security Deposit (₹)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        priceController.text.isNotEmpty &&
                        depositController.text.isNotEmpty &&
                        regController.text.isNotEmpty) {
                      Navigator.pop(ctx);
                      try {
                        await ref.read(ownerBikesProvider.notifier).addBike(
                          name: nameController.text,
                          category: category,
                          rentalPrice: double.parse(priceController.text),
                          securityDeposit: double.parse(depositController.text),
                          registrationNumber: regController.text,
                        );
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 48),
                  ),
                  child: const Text('Add'),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bikesState = ref.watch(ownerBikesProvider);

    final filteredBikes = bikesState.bikes.where((bike) {
      final matchesSearch = bike.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || bike.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Fleet'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintText: 'Search model...',
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        items: ['All', 'Cruiser', 'Sport', 'Scooter', 'Street'].map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat, overflow: TextOverflow.ellipsis));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: bikesState.isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: 5,
                    itemBuilder: (ctx, idx) => const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: ShimmerLoader(width: double.infinity, height: 120),
                    ),
                  )
                : bikesState.error != null
                    ? EmptyStateWidget(
                        icon: Icons.error_outline_rounded,
                        title: 'Load Failed',
                        message: bikesState.error!,
                        actionLabel: 'Retry',
                        onAction: () => ref.read(ownerBikesProvider.notifier).loadBikes(),
                      )
                    : filteredBikes.isEmpty
                        ? const EmptyStateWidget(
                            icon: Icons.search_off_rounded,
                            title: 'No Bikes Found',
                            message: 'Try adjusting your filters or add a new bike to your fleet.',
                          )
                        : RefreshIndicator(
                            onRefresh: () => ref.read(ownerBikesProvider.notifier).loadBikes(),
                            child: ListView.separated(
                              padding: const EdgeInsets.all(20),
                              itemCount: filteredBikes.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 16),
                              itemBuilder: (ctx, idx) {
                                final bike = filteredBikes[idx];
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(color: Theme.of(context).colorScheme.surfaceVariant),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
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
                                                    bike.name,
                                                    style: Theme.of(context).textTheme.titleLarge,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      bike.category ?? 'General',
                                                      style: TextStyle(
                                                        color: Theme.of(context).colorScheme.primary,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  bike.availabilityStatus == 'Available' ? 'Active' : 'Inactive',
                                                  style: TextStyle(
                                                    color: bike.availabilityStatus == 'Available' ? Colors.green : Colors.grey,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Switch(
                                                  value: bike.availabilityStatus == 'Available',
                                                  activeColor: Theme.of(context).colorScheme.primary,
                                                  onChanged: (val) {
                                                    ref.read(ownerBikesProvider.notifier)
                                                        .toggleAvailability(bike.id, bike.availabilityStatus);
                                                  },
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 16.0),
                                          child: Divider(),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Daily Rate', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                                Text('₹${bike.rentalPrice.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Deposit', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                                Text('₹${bike.securityDeposit.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                              ],
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                                              onPressed: () async {
                                                final confirmed = await showDialog<bool>(
                                                  context: context,
                                                  builder: (c) => AlertDialog(
                                                    title: const Text('Delete Bike'),
                                                    content: Text('Are you sure you want to delete ${bike.name}?'),
                                                    actions: [
                                                      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                                      ElevatedButton(
                                                        onPressed: () => Navigator.pop(c, true),
                                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                        child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirmed == true) {
                                                  ref.read(ownerBikesProvider.notifier).deleteBike(bike.id);
                                                }
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBikeDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Bike'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
