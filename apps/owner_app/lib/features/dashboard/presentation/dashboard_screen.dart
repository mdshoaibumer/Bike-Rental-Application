import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.indigo,
                    child: Icon(Icons.admin_panel_settings, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, Fleet Owner',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Performance Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: "Today's Revenue",
                      value: '₹${stats.todayRevenue.toStringAsFixed(0)}',
                      icon: Icons.currency_rupee,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: "Monthly Revenue",
                      value: '₹${stats.monthlyRevenue.toStringAsFixed(0)}',
                      icon: Icons.analytics_outlined,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Real-time Operations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildOperationCard(
                    title: 'Total Fleet',
                    value: '${stats.totalBikes} Bikes',
                    icon: Icons.motorcycle,
                    color: Colors.indigo,
                  ),
                  _buildOperationCard(
                    title: 'Available Now',
                    value: '${stats.availableBikes} Bikes',
                    icon: Icons.check_circle_outline,
                    color: Colors.teal,
                  ),
                  _buildOperationCard(
                    title: 'Active Rentals',
                    value: '${stats.activeRentals} Active',
                    icon: Icons.pedal_bike,
                    color: Colors.orange,
                  ),
                  _buildOperationCard(
                    title: 'Pending Approvals',
                    value: '${stats.pendingBookings} Bookings',
                    icon: Icons.pending_actions_outlined,
                    color: Colors.redAccent,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Quick Fleet Operations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildQuickActionBtn(context, label: 'Manage Bikes', icon: Icons.motorcycle, route: '/bikes', color: Colors.indigo),
                  _buildQuickActionBtn(context, label: 'Manage Bookings', icon: Icons.assignment_turned_in_outlined, route: '/bookings', color: Colors.deepOrange),
                  _buildQuickActionBtn(context, label: 'KYC & Customers', icon: Icons.verified_user_outlined, route: '/customers', color: Colors.teal),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.motorcycle), label: 'Bikes'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
        ],
        onTap: (index) {
          if (index == 1) context.push('/bikes');
          if (index == 2) context.push('/bookings');
          if (index == 3) context.push('/customers');
        },
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Icon(icon, size: 18, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionBtn(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String route,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: () => context.push(route),
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(120, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
