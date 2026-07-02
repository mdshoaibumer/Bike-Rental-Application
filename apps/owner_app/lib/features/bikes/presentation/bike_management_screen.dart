import 'package:flutter/material.dart';

class Bike {
  final String id;
  final String modelName;
  final String category;
  final double rentalPrice;
  final double securityDeposit;
  bool isAvailable;

  Bike({
    required this.id,
    required this.modelName,
    required this.category,
    required this.rentalPrice,
    required this.securityDeposit,
    required this.isAvailable,
  });
}

class BikeManagementScreen extends StatefulWidget {
  const BikeManagementScreen({super.key});

  @override
  State<BikeManagementScreen> createState() => _BikeManagementScreenState();
}

class _BikeManagementScreenState extends State<BikeManagementScreen> {
  final List<Bike> _bikes = [
    Bike(id: '1', modelName: 'Royal Enfield Classic 350', category: 'Cruiser', rentalPrice: 1200, securityDeposit: 5000, isAvailable: true),
    Bike(id: '2', modelName: 'KTM Duke 250', category: 'Sport', rentalPrice: 1500, securityDeposit: 6000, isAvailable: true),
    Bike(id: '3', modelName: 'Honda Activa 6G', category: 'Scooter', rentalPrice: 500, securityDeposit: 2000, isAvailable: false),
    Bike(id: '4', modelName: 'Yamaha FZ-S V3', category: 'Street', rentalPrice: 900, securityDeposit: 4000, isAvailable: true),
  ];

  String _searchQuery = '';
  String _selectedCategory = 'All';

  void _addBike(Bike bike) {
    setState(() {
      _bikes.add(bike);
    });
  }

  void _toggleAvailability(String id) {
    setState(() {
      final bike = _bikes.firstWhere((b) => b.id == id);
      bike.isAvailable = !bike.isAvailable;
    });
  }

  void _deleteBike(String id) {
    setState(() {
      _bikes.removeWhere((b) => b.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bike deleted (Soft Deleted)')),
    );
  }

  void _showAddBikeDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final depositController = TextEditingController();
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
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        priceController.text.isNotEmpty &&
                        depositController.text.isNotEmpty) {
                      _addBike(Bike(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        modelName: nameController.text,
                        category: category,
                        rentalPrice: double.parse(priceController.text),
                        securityDeposit: double.parse(depositController.text),
                        isAvailable: true,
                      ));
                      Navigator.pop(ctx);
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
    final filteredBikes = _bikes.where((bike) {
      final matchesSearch = bike.modelName.toLowerCase().contains(_searchQuery.toLowerCase());
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
          // Search & Filters Header
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

          // Fleet List
          Expanded(
            child: filteredBikes.isEmpty
                ? const Center(child: Text('No bikes found matching filters.'))
                : ListView.builder(
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
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        bike.modelName,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        bike.category,
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  // Available switch status indicator badge
                                  Switch(
                                    value: bike.isAvailable,
                                    onChanged: (val) => _toggleAvailability(bike.id),
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
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                        onPressed: () {
                                          // Edit logic placeholder
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Edit Bike flow initiated')),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => _deleteBike(bike.id),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
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
