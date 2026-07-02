import 'package:flutter/material.dart';

class BookingItem {
  final String id;
  final String bookingNo;
  final String customerName;
  final String bikeModel;
  final String dates;
  final double amount;
  String status; // PENDING, CONFIRMED, ACTIVE, RETURNED, COMPLETED, REJECTED
  final List<String> timeline;

  BookingItem({
    required this.id,
    required this.bookingNo,
    required this.customerName,
    required this.bikeModel,
    required this.dates,
    required this.amount,
    required this.status,
    required this.timeline,
  });
}

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<BookingItem> _bookings = [
    BookingItem(
      id: '1',
      bookingNo: 'BKG-90812',
      customerName: 'Amit Sharma',
      bikeModel: 'Royal Enfield Classic 350',
      dates: '05 Jul - 08 Jul',
      amount: 3600,
      status: 'PENDING',
      timeline: ['Booking Created (02 Jul, 10:00 AM)'],
    ),
    BookingItem(
      id: '2',
      bookingNo: 'BKG-76541',
      customerName: 'Rohan Verma',
      bikeModel: 'KTM Duke 250',
      dates: '01 Jul - 04 Jul',
      amount: 4500,
      status: 'CONFIRMED',
      timeline: ['Booking Created (28 Jun, 03:30 PM)', 'Approved by Owner (28 Jun, 05:00 PM)'],
    ),
    BookingItem(
      id: '3',
      bookingNo: 'BKG-43210',
      customerName: 'Priya Patel',
      bikeModel: 'Honda Activa 6G',
      dates: '30 Jun - 02 Jul',
      amount: 1000,
      status: 'ACTIVE',
      timeline: ['Booking Created (29 Jun, 09:12 AM)', 'Approved (29 Jun, 11:00 AM)', 'Bike Picked Up (30 Jun, 10:00 AM)'],
    ),
    BookingItem(
      id: '4',
      bookingNo: 'BKG-22114',
      customerName: 'Siddharth Sen',
      bikeModel: 'Yamaha FZ-S V3',
      dates: '25 Jun - 27 Jun',
      amount: 1800,
      status: 'COMPLETED',
      timeline: ['Booking Created', 'Approved', 'Picked Up', 'Returned', 'Completed & Paid'],
    ),
  ];

  @override
  void initState() {
    super.override() ;
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateStatus(String id, String nextStatus, String timelineUpdate) {
    setState(() {
      final b = _bookings.firstWhere((booking) => booking.id == id);
      b.status = nextStatus;
      b.timeline.add('$timelineUpdate (${DateTime.now().toString().substring(0, 16)})');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status updated to $nextStatus')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList('PENDING'),
          _buildBookingList('CONFIRMED'),
          _buildBookingList('ACTIVE'),
          _buildBookingList('COMPLETED'),
        ],
      ),
    );
  }

  Widget _buildBookingList(String filterStatus) {
    final filtered = _bookings.where((b) => b.status == filterStatus).toList();

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

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filtered.length,
      itemBuilder: (ctx, idx) {
        final booking = filtered[idx];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ExpansionTile(
            title: Text(
              '${booking.bookingNo} • ${booking.customerName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${booking.bikeModel} | ${booking.dates}'),
            trailing: _buildStatusBadge(booking.status),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Total Amount: ₹${booking.amount}'),
                    const SizedBox(height: 16),
                    const Text('Timeline & Logs', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...booking.timeline.map((log) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, size: 14, color: Colors.indigo),
                              const SizedBox(width: 8),
                              Expanded(child: Text(log, style: const TextStyle(fontSize: 12))),
                            ],
                          ),
                        )),
                    const SizedBox(height: 20),
                    _buildActionButtons(booking),
                  ],
                ),
              )
            ],
          ),
        );
      },
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

  Widget _buildActionButtons(BookingItem booking) {
    if (booking.status == 'PENDING') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => _updateStatus(booking.id, 'REJECTED', 'Booking Rejected'),
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _updateStatus(booking.id, 'CONFIRMED', 'Booking Approved'),
            child: const Text('Approve'),
          ),
        ],
      );
    } else if (booking.status == 'CONFIRMED') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () => _updateStatus(booking.id, 'ACTIVE', 'Bike Handed Over & Picked Up'),
            child: const Text('Mark Bike Picked Up'),
          ),
        ],
      );
    } else if (booking.status == 'ACTIVE') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () => _updateStatus(booking.id, 'COMPLETED', 'Bike Returned & Completed'),
            child: const Text('Mark Bike Returned & Complete'),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
