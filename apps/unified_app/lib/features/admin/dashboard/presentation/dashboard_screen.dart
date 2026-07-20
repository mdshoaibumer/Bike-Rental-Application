import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/widgets/empty_state_widget.dart';
import 'package:shared/widgets/shimmer_loader.dart';
import 'package:shared/theme/app_theme.dart';
import '../../../../core/admin_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            floating: true,
            pinned: true,
            title: Text(
              'Partner Dashboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).appBarTheme.iconTheme?.color,
                  ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push('/settings'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          statsAsync.when(
            loading: () => SliverFillRemaining(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const ShimmerLoader(width: double.infinity, height: 160),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: List.generate(4, (_) => const ShimmerLoader(width: double.infinity, height: double.infinity)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            error: (err, _) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
            data: (stats) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            child: Icon(Icons.storefront_rounded, color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fleet Owner',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Overview of your business',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Revenue',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            context,
                            title: "Today",
                            value: '₹${stats.todayRevenue.toStringAsFixed(0)}',
                            icon: Icons.trending_up_rounded,
                            gradient: LinearGradient(
                              colors: [Colors.green[600]!, Colors.green[400]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildMetricCard(
                            context,
                            title: "This Month",
                            value: '₹${stats.monthlyRevenue.toStringAsFixed(0)}',
                            icon: Icons.account_balance_wallet_rounded,
                            gradient: LinearGradient(
                              colors: [Theme.of(context).colorScheme.primary, Colors.blue[400]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Fleet Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildOperationCard(
                          context,
                          title: 'Total Bikes',
                          value: '${stats.totalBikes}',
                          icon: Icons.electric_moped_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        _buildOperationCard(
                          context,
                          title: 'Available',
                          value: '${stats.availableBikes}',
                          icon: Icons.check_circle_outline_rounded,
                          color: Colors.teal,
                        ),
                        _buildOperationCard(
                          context,
                          title: 'On Rent',
                          value: '${stats.activeRentals}',
                          icon: Icons.timer_outlined,
                          color: Colors.orange,
                        ),
                        _buildOperationCard(
                          context,
                          title: 'Pending',
                          value: '${stats.pendingBookings}',
                          icon: Icons.hourglass_empty_rounded,
                          color: Colors.redAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildQuickActionBtn(context, label: 'Bikes', icon: Icons.electric_moped_rounded, route: '/bikes'),
                        _buildQuickActionBtn(context, label: 'Bookings', icon: Icons.receipt_long_rounded, route: '/bookings'),
                        _buildQuickActionBtn(context, label: 'Customers', icon: Icons.people_outline_rounded, route: '/customers'),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.electric_moped_rounded), label: 'Bikes'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline_rounded), label: 'Customers'),
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
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: gradient.colors.first.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
              Icon(icon, color: Colors.white, size: 24),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOperationCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildQuickActionBtn(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String route,
  }) {
    return ActionChip(
      onPressed: () => context.push(route),
      avatar: Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.surfaceVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
