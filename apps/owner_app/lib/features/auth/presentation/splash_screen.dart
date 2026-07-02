import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OwnerSplashScreen extends StatefulWidget {
  const OwnerSplashScreen({super.key});

  @override
  State<OwnerSplashScreen> createState() => _OwnerSplashScreenState();
}

class _OwnerSplashScreenState extends State<OwnerSplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
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
