import 'package:go_router/go_router.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/bikes/presentation/bike_management_screen.dart';
import '../features/bookings/presentation/booking_management_screen.dart';
import '../features/customers/presentation/customer_management_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OwnerSplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const OwnerLoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/bikes',
      builder: (context, state) => const BikeManagementScreen(),
    ),
    GoRoute(
      path: '/bookings',
      builder: (context, state) => const BookingManagementScreen(),
    ),
    GoRoute(
      path: '/customers',
      builder: (context, state) => const CustomerManagementScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const OwnerSettingsScreen(),
    ),
  ],
);
