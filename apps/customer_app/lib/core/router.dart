import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/storage/secure_storage.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/bikes/presentation/bike_list_screen.dart';
import '../features/bikes/presentation/bike_detail_screen.dart';
import '../features/booking/presentation/booking_history_screen.dart';
import '../features/profile/presentation/profile_screen.dart';

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
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/bikes',
      builder: (context, state) => const BikeListScreen(),
    ),
    GoRoute(
      path: '/bike/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BikeDetailScreen(bikeId: id);
      },
    ),
    GoRoute(
      path: '/bookings',
      builder: (context, state) => const BookingHistoryScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
