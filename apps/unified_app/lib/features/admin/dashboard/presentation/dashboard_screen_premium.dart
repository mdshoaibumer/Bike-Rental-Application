import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/widgets/premium_app_bar.dart';
import 'package:shared/widgets/glass_morphism_container.dart';
import 'package:shared/widgets/stat_card.dart';
import 'package:shared/theme/app_theme.dart';
import 'package:shared/widgets/empty_state_widget.dart';
import 'package:shared/widgets/shimmer_loader.dart';
import '../../../../core/admin_providers.dart';

class DashboardScreenPremium extends ConsumerWidget {
  const DashboardScreenPremium({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Premium Hero App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: true,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.storefront_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Fleet Management',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Executive Dashboard',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8, top: 8),
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white),
                  onPressed: () => context.push('/admin/settings'),
                ),
              ),
            ],
          ),

          // Content
          statsAsync.when(
            loading: () => SliverFillRemaining(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const ShimmerLoader(width: double.infinity, height: 120),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: List.generate(
                          4,
                          (_) => const ShimmerLoader(
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(
                child: EmptyStateWidget(
                  icon: Icons.error_outline_rounded,
                  title: 'Failed to Load Dashboard',
                  message: err.toString(),
                  actionLabel: 'Retry',
                  onAction: () {
                    ref.invalidate(dashboardStatsProvider);
                  },
                ),
              ),
            ),
            data: (stats) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KPI Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: 'Total Revenue',
                            value: '₹${stats.totalRevenue.toStringAsFixed(0)}',
                            icon: Icons.trending_up_rounded,
                            color: AppTheme._successGreen,
                            subValue: '+12% this month',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            label: 'Active Bikes',
                            value: '${stats.activeBikes}',
                            icon: Icons.two_wheeler_rounded,
                            color: AppTheme._primaryBlue,
                            subValue: '${stats.totalBikes} total',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: 'Today\'s Bookings',
                            value: '${stats.todayBookings}',
                            icon: Icons.calendar_today_rounded,
                            color: AppTheme._accentOrange,
                            subValue: '${stats.totalBookings} total',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            label: 'Avg Rating',
                            value: '${stats.averageRating.toStringAsFixed(1)}',
                            icon: Icons.star_rounded,
                            color: AppTheme._warningAmber,
                            subValue: 'from ${stats.totalReviews} reviews',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Management Sections
                    Text(
                      'Quick Management',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Management Cards Grid
                    GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildManagementCard(
                          context,
                          icon: Icons.two_wheeler_rounded,
                          title: 'Manage Bikes',
                          subtitle: 'Add, edit, or remove bikes',
                          color: AppTheme._primaryBlue,
                          onTap: () => context.push('/admin/bikes'),
                        ),
                        _buildManagementCard(
                          context,
                          icon: Icons.calendar_month_rounded,
                          title: 'View Bookings',
                          subtitle: 'Track all reservations',
                          color: AppTheme._accentOrange,
                          onTap: () => context.push('/admin/bookings'),
                        ),
                        _buildManagementCard(
                          context,
                          icon: Icons.people_rounded,
                          title: 'Customers',
                          subtitle: 'Manage customer data',
                          color: AppTheme._successGreen,
                          onTap: () => context.push('/admin/customers'),
                        ),
                        _buildManagementCard(
                          context,
                          icon: Icons.assessment_rounded,
                          title: 'Reports',
                          subtitle: 'Analytics & insights',
                          color: AppTheme._warningAmber,
                          onTap: () => context.push('/admin/reports'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Recent Activity Section
                    Text(
                      'Recent Activity',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActivityTimeline(context),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: color, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme._textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTimeline(BuildContext context) {
    final activities = [
      ('2 min ago', 'New booking from Rajesh Kumar', Icons.check_circle_rounded),
      ('1 hour ago', 'Bike maintenance completed - ID: BK-002', Icons.build_rounded),
      ('3 hours ago', 'Payment received - ₹480', Icons.payment_rounded),
    ];

    return Column(
      children: List.generate(
        activities.length,
        (index) {
          final (time, description, icon) = activities[index];
          final isLast = index == activities.length - 1;

          return Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme._primaryBlue.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: AppTheme._primaryBlue,
                            size: 20,
                          ),
                        ),
                        if (!isLast)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Container(
                              width: 2,
                              height: 20,
                              color: AppTheme._primaryBlue.withValues(alpha: 0.2),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          time,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme._textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isLast) const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
