import 'package:flutter/material.dart';
import 'package:shared/widgets/primary_button.dart';

class BikeDetailScreen extends StatelessWidget {
  final String bikeId;
  const BikeDetailScreen({super.key, required this.bikeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bike Details - $bikeId')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 80),
            ),
            const SizedBox(height: 16),
            const Text('Super Sport Bike', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('\$25 / day', style: TextStyle(fontSize: 18, color: Colors.blue)),
            const SizedBox(height: 16),
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('A high performance bike for all your riding needs. Excellent mileage and top speed.'),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Book Now',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking flow initiated!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
