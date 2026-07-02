import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';

class BookingManagementScreen extends ConsumerStatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  ConsumerState<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends ConsumerState<BookingManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Future.microtask(() => ref.read(ownerBookingsProvider.notifier).loadBookings());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsState = ref.watch(ownerBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Reservations'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: bookingsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingsState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(bookingsState.error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.read(ownerBookingsProvider.notifier).loadBookings(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingList(bookingsState.bookings, 'PENDING'),
                    _buildBookingList(bookingsState.bookings, 'CONFIRMED'),
                    _buildBookingList(bookingsState.bookings, 'ACTIVE'),
                    _buildBookingList(bookingsState.bookings, 'COMPLETED'),
                  ],
                ),
    );
  }

  Widget _buildBookingList(List<OwnerBooking> allBookings, String filterStatus) {
    final filtered = allBookings.where((b) => b.status == filterStatus).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('No bookings under $filterStatus', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(ownerBookingsProvider.notifier).loadBookings(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: filtered.length,
        itemBuilder: (ctx, idx) {
          final booking = filtered[idx];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                              booking.customerName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(booking.bikeName, style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      _buildStatusBadge(booking.status),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${booking.pickupDate} → ${booking.returnDate}',
                          style: const TextStyle(fontSize: 12)),
                      Text('₹${booking.amount.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildActionButtons(booking),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'PENDING':
        bg = Colors.amber.shade100;
        fg = Colors.amber.shade900;
        break;
      case 'CONFIRMED':
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade900;
        break;
      case 'ACTIVE':
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade900;
        break;
      case 'COMPLETED':
        bg = Colors.green.shade100;
        fg = Colors.green.shade900;
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade900;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionButtons(OwnerBooking booking) {
    final notifier = ref.read(ownerBookingsProvider.notifier);

    if (booking.status == 'PENDING') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => notifier.rejectBooking(booking.id),
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => notifier.approveBooking(booking.id),
            child: const Text('Approve'),
          ),
        ],
      );
    } else if (booking.status == 'CONFIRMED') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () => notifier.markPickedUp(booking.id),
            child: const Text('Mark Picked Up'),
          ),
        ],
      );
    } else if (booking.status == 'ACTIVE') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () => notifier.markReturned(booking.id),
            child: const Text('Mark Returned'),
          ),
        ],
      );
    } else if (booking.status == 'RETURNED') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () => notifier.completeBooking(booking.id),
            child: const Text('Complete & Close'),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
