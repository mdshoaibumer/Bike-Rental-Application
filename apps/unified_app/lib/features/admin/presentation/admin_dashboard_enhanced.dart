import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/widgets/chart_widget.dart';
import 'package:shared/widgets/stat_card.dart';
import 'package:shared/widgets/gradient_card.dart';
import 'package:shared/theme/app_theme.dart';

class AdminDashboardEnhanced extends ConsumerWidget {
  const AdminDashboardEnhanced({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryBlue.withOpacity(0.1),
            ),
            child: const Icon(Icons.account_circle_rounded),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Key Metrics
              Text(
                'Key Metrics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Total Users',
                      value: '2.4K',
                      icon: Icons.people_rounded,
                      showTrend: true,
                      trendUp: true,
                      trendPercentage: '+8.2%',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Total Revenue',
                      value: '₹45.2K',
                      icon: Icons.trending_up_rounded,
                      gradient: AppTheme.accentGradient,
                      showTrend: true,
                      trendUp: true,
                      trendPercentage: '+12.5%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Active Bookings',
                      value: '156',
                      icon: Icons.booking_rounded,
                      gradient: AppTheme.successGradient,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Bikes Available',
                      value: '84/120',
                      icon: Icons.two_wheeler_rounded,
                      showTrend: true,
                      trendUp: false,
                      trendPercentage: '-5%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Revenue Chart
              Text(
                'Revenue Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              GradientCard(
                gradient: null,
                padding: const EdgeInsets.all(16),
                onTap: () {},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'This Month',
                          style:
                              Theme.of(context).textTheme.labelLarge,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Text(
                            '+18% vs last month',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppTheme.accentOrange,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: ChartWidget(
                        data: {
                          'Mon': 4000,
                          'Tue': 3000,
                          'Wed': 2000,
                          'Thu': 2780,
                          'Fri': 1890,
                          'Sat': 2390,
                          'Sun': 3490,
                        },
                        type: ChartType.line,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Bookings Status
              Text(
                'Recent Bookings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GradientCard(
                    gradient: null,
                    padding: const EdgeInsets.all(16),
                    onTap: () => context.push('/admin/booking/$index'),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Booking #${1000 + index}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Honda CB350 • 2 days',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${1798 + (index * 200)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              decoration: BoxDecoration(
                                color: [
                                  AppTheme.successGreen,
                                  AppTheme.accentOrange,
                                  AppTheme.primaryBlue,
                                ][index % 3].withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              child: Text(
                                [
                                  'Completed',
                                  'In Progress',
                                  'Pending',
                                ][index % 3],
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: [
                                        AppTheme.successGreen,
                                        AppTheme.accentOrange,
                                        AppTheme.primaryBlue,
                                      ][index % 3],
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/admin/bookings'),
                  child: const Text('View All Bookings'),
                ),
              ),
              const SizedBox(height: 32),

              // Top Performing Bikes
              Text(
                'Top Bikes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GradientCard(
                    gradient: null,
                    padding: const EdgeInsets.all(16),
                    onTap: () => context.push('/admin/bike/${index + 1}'),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.two_wheeler_rounded,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                [
                                  'Honda CB350',
                                  'Yamaha MT-07',
                                  'KTM Duke 390',
                                ][index],
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${45 - (index * 5)} bookings',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${45000 - (index * 5000)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.accentOrange
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              child: Text(
                                'Active',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppTheme.accentOrange,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
