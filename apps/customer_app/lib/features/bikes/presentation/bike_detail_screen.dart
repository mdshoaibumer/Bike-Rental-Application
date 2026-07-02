import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/widgets/primary_button.dart';
import '../providers/bike_provider.dart';
import '../../booking/providers/booking_provider.dart';

class BikeDetailScreen extends ConsumerStatefulWidget {
  final String bikeId;
  const BikeDetailScreen({super.key, required this.bikeId});

  @override
  ConsumerState<BikeDetailScreen> createState() => _BikeDetailScreenState();
}

class _BikeDetailScreenState extends ConsumerState<BikeDetailScreen> {
  DateTimeRange? _selectedDates;
  bool _isBooking = false;

  @override
  Widget build(BuildContext context) {
    final bikeAsync = ref.watch(bikeDetailProvider(widget.bikeId));

    return Scaffold(
      appBar: AppBar(title: const Text('Bike Details')),
      body: bikeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
        ),
        data: (bike) {
          if (bike == null) {
            return const Center(child: Text('Bike not found'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: bike.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(bike.imageUrl!, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.motorcycle, size: 80, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Text(
                  bike.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${bike.rentalPrice.toStringAsFixed(0)} / day',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (bike.registrationNumber != null) ...[
                  const SizedBox(height: 8),
                  Text('Reg: ${bike.registrationNumber}',
                      style: TextStyle(color: Colors.grey[600])),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    _infoChip(Icons.speed, '${bike.cc ?? "-"} CC'),
                    const SizedBox(width: 8),
                    _infoChip(Icons.local_gas_station, bike.fuelType ?? 'Petrol'),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Select Dates',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_selectedDates != null
                      ? '${_formatDate(_selectedDates!.start)} - ${_formatDate(_selectedDates!.end)}'
                      : 'Choose pickup & return dates'),
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (range != null) {
                      setState(() => _selectedDates = range);
                    }
                  },
                ),
                if (_selectedDates != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Total: ₹${(bike.rentalPrice * _selectedDates!.duration.inDays).toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
                const SizedBox(height: 32),
                PrimaryButton(
                  text: _isBooking ? 'Booking...' : 'Book Now',
                  onPressed: _selectedDates == null || _isBooking
                      ? null
                      : () => _handleBook(bike.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Future<void> _handleBook(String bikeId) async {
    if (_selectedDates == null) return;
    setState(() => _isBooking = true);
    try {
      await ref.read(bookingsProvider.notifier).createBooking(
        bikeId: bikeId,
        pickupDate: _selectedDates!.start,
        returnDate: _selectedDates!.end,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking created successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }
}
