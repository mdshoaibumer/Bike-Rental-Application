import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/booking_provider.dart';

class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  ConsumerState<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(bookingsProvider.notifier).loadBookings());
  }

  @override
  Widget build(BuildContext context) {
    final bookingsState = ref.watch(bookingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: bookingsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingsState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(bookingsState.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(bookingsProvider.notifier).loadBookings(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : bookingsState.bookings.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No bookings yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref.read(bookingsProvider.notifier).loadBookings(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: bookingsState.bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookingsState.bookings[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(
                                'Booking #${booking.bookingNumber}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Status: ${booking.bookingStatus}\n₹${booking.finalAmount.toInt()} • ${booking.durationDays} days',
                              ),
                              isThreeLine: true,
                              trailing: _buildStatusChip(booking.bookingStatus),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'CONFIRMED':
        color = Colors.green;
        break;
      case 'ACTIVE':
        color = Colors.blue;
        break;
      case 'COMPLETED':
        color = Colors.grey;
        break;
      case 'CANCELLED':
      case 'REJECTED':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }
    return Chip(
      label: Text(status, style: TextStyle(color: color, fontSize: 11)),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide.none,
      padding: EdgeInsets.zero,
    );
  }
}
