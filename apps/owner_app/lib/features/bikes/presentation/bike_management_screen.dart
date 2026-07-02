import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';

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
              title: const Text('Add New Bike'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Model Name / Brand'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: regController,
                      decoration: const InputDecoration(labelText: 'Registration Number'),
                    ),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Daily Rental Price (₹)'),
                    ),
                    const SizedBox(height: 12),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showAddBikeDialog,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search model...',
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: ['All', 'Cruiser', 'Sport', 'Scooter', 'Street'].map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: bikesState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : bikesState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(bikesState.error!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => ref.read(ownerBikesProvider.notifier).loadBikes(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredBikes.isEmpty
                        ? const Center(child: Text('No bikes found matching filters.'))
                        : RefreshIndicator(
                            onRefresh: () => ref.read(ownerBikesProvider.notifier).loadBikes(),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: filteredBikes.length,
                              itemBuilder: (ctx, idx) {
                                final bike = filteredBikes[idx];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
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
                                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    bike.category ?? 'General',
                                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Switch(
                                              value: bike.availabilityStatus == 'Available',
                                              onChanged: (val) {
                                                ref.read(ownerBikesProvider.notifier)
                                                    .toggleAvailability(bike.id, bike.availabilityStatus);
                                              },
                                            )
                                          ],
                                        ),
                                        const Divider(height: 20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Daily: ₹${bike.rentalPrice.toInt()}  |  Deposit: ₹${bike.securityDeposit.toInt()}',
                                              style: const TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                                              onPressed: () async {
                                                final confirmed = await showDialog<bool>(
                                                  context: context,
                                                  builder: (c) => AlertDialog(
                                                    title: const Text('Delete Bike'),
                                                    content: Text('Delete ${bike.name}?'),
                                                    actions: [
                                                      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                                      TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBikeDialog,
        tooltip: 'Add Bike',
        child: const Icon(Icons.add),
      ),
    );
  }
}
