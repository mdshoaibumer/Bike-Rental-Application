import 'package:go_router/go_router.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/bikes/presentation/bike_list_screen.dart';
import '../features/bikes/presentation/bike_detail_screen.dart';
import '../features/booking/presentation/booking_history_screen.dart';
import '../features/profile/presentation/profile_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
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
