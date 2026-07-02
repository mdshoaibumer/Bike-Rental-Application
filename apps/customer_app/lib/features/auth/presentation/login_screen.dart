import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/widgets/primary_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Send OTP',
              onPressed: () {
                // Mock login flow
                context.go('/home');
              },
            ),
          ],
        ),
      ),
    );
  }
}
