import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/widgets/primary_button.dart';
import 'package:shared/widgets/shimmer_loader.dart';
import 'package:shared/widgets/empty_state_widget.dart';
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
      body: bikeAsync.when(
        loading: () => const Center(child: ShimmerLoader(width: double.infinity, height: 300)),
        error: (err, _) => Center(
          child: EmptyStateWidget(
            icon: Icons.error_outline_rounded,
            title: 'Failed to load',
            message: err.toString(),
            actionLabel: 'Go Back',
            onAction: () => context.pop(),
          ),
        ),
        data: (bike) {
          if (bike == null) {
            return const Center(
              child: EmptyStateWidget(
                icon: Icons.search_off_rounded,
                title: 'Not Found',
                message: 'This bike is no longer available.',
              ),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'bike_img_${bike.id}',
                    child: bike.imageUrl != null
                        ? Image.network(bike.imageUrl!, fit: BoxFit.cover)
                        : Container(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: const Icon(Icons.motorcycle, size: 100, color: Colors.grey),
                          ),
                  ),
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bike.bikeName,
                                  style: Theme.of(context).textTheme.headlineLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  bike.brand,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '₹${bike.rentalPrice.toStringAsFixed(0)} / day',
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Specifications',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _specCard(Icons.speed_rounded, 'Engine', '${bike.engineCC > 0 ? bike.engineCC : "-"} CC')),
                          const SizedBox(width: 16),
                          Expanded(child: _specCard(Icons.local_gas_station_rounded, 'Fuel', bike.fuelType)),
                        ],
                      ),
                      if (bike.registrationNumber != null) ...[
                        const SizedBox(height: 16),
                        _specCard(Icons.assignment_rounded, 'Registration', bike.registrationNumber!),
                      ],
                      const SizedBox(height: 32),
                      Text(
                        'Rental Period',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final range = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 90)),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(context).colorScheme.copyWith(
                                      primary: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                              child: child!,
                            ),
                          );
                          if (range != null) {
                            setState(() => _selectedDates = range);
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_month_rounded, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dates',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                    Text(
                                      _selectedDates != null
                                          ? '${_formatDate(_selectedDates!.start)} - ${_formatDate(_selectedDates!.end)}'
                                          : 'Select pickup & return dates',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              if (_selectedDates != null)
                                Text(
                                  '${_selectedDates!.duration.inDays} Days',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 120), // padding for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomSheet: bikeAsync.hasValue && bikeAsync.value != null
          ? Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Price', style: TextStyle(color: Colors.grey[600])),
                          Text(
                            _selectedDates != null
                                ? '₹${(bikeAsync.value!.rentalPrice * _selectedDates!.duration.inDays).toStringAsFixed(0)}'
                                : '₹0',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        text: _isBooking ? 'Processing...' : 'Book Now',
                        isLoading: _isBooking,
                        onPressed: _selectedDates == null || _isBooking
                            ? null
                            : () => _handleBook(bikeAsync.value!.id),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _specCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}';

  Future<void> _handleBook(String bikeId) async {
    if (_selectedDates == null) return;
    setState(() => _isBooking = true);
    try {
      await ref.read(bookingsProvider.notifier).createBooking(
        bikeId,
        _selectedDates!.start,
        _selectedDates!.end,
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
