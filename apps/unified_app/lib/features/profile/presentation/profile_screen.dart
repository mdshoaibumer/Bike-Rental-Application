import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/theme/app_theme.dart';
import '../../../core/providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = authState.user?['name'] ?? 'User';
    final userMobile = authState.user?['mobile'] ?? '';
    final kycStatus = authState.user?['kyc_status'] ?? 'PENDING';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Premium Header with Background
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.black45 : Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.white,
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black45 : Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    color: Colors.white,
                    onPressed: () {/* settings */},
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Avatar with Initial
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white24,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Center(
                            child: Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userMobile,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Profile Completion Progress
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Profile 75% Complete',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Stats Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.two_wheeler_rounded,
                      label: 'Total Rides',
                      value: '12',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.star_rounded,
                      label: 'Rating',
                      value: '4.8',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.calendar_today_rounded,
                      label: 'Member',
                      value: '6m',
                    ),
                  ),
                ],
              ),
            ),
          ),
          // About Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    context,
                    icon: Icons.verified_user_rounded,
                    title: 'KYC Verification',
                    subtitle: 'Identity verification',
                    trailing: _buildKYCBadge(kycStatus),
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _buildMenuCard(
                    context,
                    icon: Icons.payment_rounded,
                    title: 'Payment Methods',
                    subtitle: '1 card saved',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _buildMenuCard(
                    context,
                    icon: Icons.notifications_rounded,
                    title: 'Notifications',
                    subtitle: 'Manage alerts',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          // Activity Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    context,
                    icon: Icons.history_rounded,
                    title: 'Booking History',
                    subtitle: 'View past bookings',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/bookings'),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuCard(
                    context,
                    icon: Icons.star_outline_rounded,
                    title: 'Reviews',
                    subtitle: 'Your ratings & reviews',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          // Support Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Help',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    context,
                    icon: Icons.help_outline_rounded,
                    title: 'Support',
                    subtitle: 'Contact our team',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _buildMenuCard(
                    context,
                    icon: Icons.description_outlined,
                    title: 'Terms & Privacy',
                    subtitle: 'Legal information',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _buildMenuCard(
                    context,
                    icon: Icons.info_outline_rounded,
                    title: 'About App',
                    subtitle: 'Version 1.0.0',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          // Logout Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: Colors.red.withOpacity(0.4),
                  ),
                  onPressed: () => _showLogoutDialog(context, ref),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, size: 20, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme._primaryBlue, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme._textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme._primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme._primaryBlue, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme._textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              DefaultTextStyle(
                style: TextStyle(color: AppTheme._textSecondary),
                child: trailing,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKYCBadge(String status) {
    Color color;
    IconData icon;
    String label;
    switch (status.toUpperCase()) {
      case 'APPROVED':
        color = AppTheme._successGreen;
        icon = Icons.check_circle_rounded;
        label = 'Verified';
        break;
      case 'PENDING':
        color = AppTheme._warningAmber;
        icon = Icons.schedule_rounded;
        label = 'Pending';
        break;
      case 'REJECTED':
        color = AppTheme._errorRed;
        icon = Icons.cancel_rounded;
        label = 'Failed';
        break;
      default:
        color = AppTheme._textSecondary;
        icon = Icons.help_outline_rounded;
        label = 'Unknown';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout? You\'ll need to sign in again to access your bookings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx, true);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.red.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
