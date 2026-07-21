import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/storage/secure_storage.dart';
import 'providers.dart';

// Common screens
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/login_screen.dart';

// Customer screens
import '../features/home/presentation/home_screen_enhanced.dart';
import '../features/bikes/presentation/bike_list_screen_premium.dart';
import '../features/bikes/presentation/bike_detail_screen_enhanced.dart';
import '../features/booking/presentation/booking_history_screen.dart';
import '../features/profile/presentation/profile_screen_premium.dart';

// Admin screens
import '../features/admin/dashboard/presentation/dashboard_screen_premium.dart';
import '../features/admin/bikes/presentation/bike_management_screen.dart';
import '../features/admin/bookings/presentation/booking_management_screen.dart';
import '../features/admin/customers/presentation/customer_management_screen.dart';
import '../features/admin/settings/presentation/settings_screen.dart';

final _storage = SecureStorage();

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (BuildContext context, GoRouterState state) async {
    final token = await _storage.getToken();
    final isLoggedIn = token != null && token.isNotEmpty;
    final isAuthRoute = state.matchedLocation == '/' || state.matchedLocation == '/login';
    
    if (!isLoggedIn && !isAuthRoute) {
      return '/login';
    }

    if (isLoggedIn) {
      final roleStr = await _storage.getRole();
      final AppRole role = roleStr == 'ADMIN' ? AppRole.admin : (roleStr == 'STAFF' ? AppRole.staff : AppRole.customer);

      // Protect against unauthorized access
      final isAdminRoute = state.matchedLocation.startsWith('/admin');
      
      if (isAdminRoute && role != AppRole.admin) {
        return '/home'; // Customer trying to access Admin
      }
      if (!isAdminRoute && !isAuthRoute && role == AppRole.admin) {
        return '/admin/dashboard'; // Admin trying to access Customer
      }
      
      // If authenticating and logged in, redirect to correct dashboard
      if (isAuthRoute && state.matchedLocation == '/login') {
        if (role == AppRole.admin) return '/admin/dashboard';
        return '/home';
      }
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    // CUSTOMER ROUTES
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreenEnhanced(),
    ),
    GoRoute(
      path: '/bikes',
      builder: (context, state) => const BikeListScreenPremium(),
    ),
    GoRoute(
      path: '/bike/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BikeDetailScreenEnhanced(bikeId: id);
      },
    ),
    GoRoute(
      path: '/bookings',
      builder: (context, state) => const BookingHistoryScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreenPremium(),
    ),
    // ADMIN ROUTES
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const DashboardScreenPremium(),
    ),
    GoRoute(
      path: '/admin/bikes',
      builder: (context, state) => const BikeManagementScreen(),
    ),
    GoRoute(
      path: '/admin/bookings',
      builder: (context, state) => const BookingManagementScreen(),
    ),
    GoRoute(
      path: '/admin/customers',
      builder: (context, state) => const CustomerManagementScreen(),
    ),
    GoRoute(
      path: '/admin/settings',
      builder: (context, state) => const OwnerSettingsScreen(),
    ),
  ],
);
