import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers.dart';

class OwnerSplashScreen extends ConsumerStatefulWidget {
  const OwnerSplashScreen({super.key});

  @override
  ConsumerState<OwnerSplashScreen> createState() => _OwnerSplashScreenState();
}

class _OwnerSplashScreenState extends ConsumerState<OwnerSplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await ref.read(ownerAuthProvider.notifier).checkAuth();
    if (!mounted) return;
    final authState = ref.read(ownerAuthProvider);
    if (authState.isAuthenticated) {
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade900,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.admin_panel_settings_outlined,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 24),
            Text(
              'BIKE RENTAL HUB',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'Owner & Partner Console',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
