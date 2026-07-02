import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BikeListScreen extends StatelessWidget {
  const BikeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Bikes')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => context.push('/bike/$index'),
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.motorcycle, size: 48),
                  const SizedBox(height: 8),
                  Text('Bike $index', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text('\$15/day'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
