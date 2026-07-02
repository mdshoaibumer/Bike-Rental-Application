import 'package:flutter/material.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text('Booking #BKG-100$index'),
              subtitle: const Text('Status: CONFIRMED\nDates: Oct 10 - Oct 12'),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}
