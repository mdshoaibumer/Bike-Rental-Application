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
      appBar: AppBar(
        title: const Text('My Bookings'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 8,
      ),
      body: bookingsState.isLoading && bookingsState.bookings.isEmpty
          ? ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) => const ShimmerLoader(width: double.infinity, height: 140),
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
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: bookingsState.bookings.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final booking = bookingsState.bookings[index];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                                    width: 1,
                                  ),
                                  color: Theme.of(context).colorScheme.surface,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 12,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
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
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          _buildStatusChip(booking.bookingStatus),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Amount',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                '₹${booking.finalAmount.toInt()}',
                                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Duration',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                '${booking.durationDays} Days',
                                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
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
