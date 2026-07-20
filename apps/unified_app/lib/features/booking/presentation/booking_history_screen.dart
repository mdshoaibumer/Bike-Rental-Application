import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/widgets/empty_state_widget.dart';
import 'package:shared/widgets/shimmer_loader.dart';
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
      body: bookingsState.isLoading && bookingsState.bookings.isEmpty
          ? ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) => const ShimmerLoader(width: double.infinity, height: 120),
            )
          : bookingsState.error != null
              ? EmptyStateWidget(
                  icon: Icons.error_outline_rounded,
                  title: 'Oops!',
                  message: bookingsState.error!,
                  actionLabel: 'Retry',
                  onAction: () => ref.read(bookingsProvider.notifier).loadBookings(),
                )
              : bookingsState.bookings.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.receipt_long_rounded,
                      title: 'No Bookings Yet',
                      message: 'You haven\'t rented any bikes yet. Explore our fleet and book your first ride!',
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref.read(bookingsProvider.notifier).loadBookings(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: bookingsState.bookings.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final booking = bookingsState.bookings[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.surfaceVariant,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Booking #${booking.bookingNumber}',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      _buildStatusChip(booking.bookingStatus),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Amount', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                          Text(
                                            '₹${booking.finalAmount.toInt()}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('Duration', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                          Text(
                                            '${booking.durationDays} Days',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                        ],
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
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    Color bgColor;
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        color = Colors.green[700]!;
        bgColor = Colors.green[50]!;
        break;
      case 'ACTIVE':
        color = Colors.blue[700]!;
        bgColor = Colors.blue[50]!;
        break;
      case 'COMPLETED':
        color = Colors.grey[700]!;
        bgColor = Colors.grey[100]!;
        break;
      case 'CANCELLED':
      case 'REJECTED':
        color = Colors.red[700]!;
        bgColor = Colors.red[50]!;
        break;
      default:
        color = Colors.orange[700]!;
        bgColor = Colors.orange[50]!;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
