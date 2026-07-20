import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/widgets/primary_button.dart';
import '../../../core/providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  
  final _adminIdController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  
  bool _otpSent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _adminIdController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  void _handleSendOtp() async {
    final mobile = _phoneController.text.trim();
    if (mobile.isEmpty || mobile.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await ref.read(authProvider.notifier).sendOTP(mobile);
    setState(() {
      _isLoading = false;
      _otpSent = true;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code sent!')),
      );
    }
  }

  void _handleVerifyOtp() async {
    final mobile = _phoneController.text.trim();
    final code = _otpController.text.trim();

    if (code.isEmpty || code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter 6-digit code')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await ref.read(authProvider.notifier).verifyOTP(mobile, code);
    setState(() => _isLoading = false);

    if (success && mounted) {
      final role = ref.read(authProvider).role;
      if (role == AppRole.admin) {
        context.go('/admin/dashboard');
      } else {
        context.go('/home');
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid or expired verification code')),
      );
    }
  }

  void _handlePasswordLogin() async {
    final id = _adminIdController.text.trim();
    final password = _adminPasswordController.text;

    if (id.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter credentials')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await ref.read(authProvider.notifier).loginWithPassword(id, password);
    setState(() => _isLoading = false);

    if (success && mounted) {
      final role = ref.read(authProvider).role;
      if (role == AppRole.admin) {
        context.go('/admin/dashboard');
      } else {
        context.go('/home');
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials')),
      );
    }
  }

  Widget _buildCustomerLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        if (!_otpSent) ...[
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Mobile Number',
              prefixIcon: const Icon(Icons.phone_android_rounded),
              hintText: '+91 9876543210',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Send Verification Code',
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _handleSendOtp,
          ),
        ] else ...[
          TextField(
            controller: _otpController,
            decoration: InputDecoration(
              labelText: 'Verification Code',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Verify & Login',
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _handleVerifyOtp,
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _otpSent = false),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              child: const Text('Change phone number'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAdminLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        TextField(
          controller: _adminIdController,
          decoration: InputDecoration(
            labelText: 'Email or Mobile Number',
            prefixIcon: const Icon(Icons.person_outline_rounded),
            hintText: 'admin@bikerental.com',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _adminPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          text: 'Login to Dashboard',
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _handlePasswordLogin,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Container(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.electric_moped_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to\nBike Rental',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
              ),
              const SizedBox(height: 32),
              TabBar(
                controller: _tabController,
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Customer'),
                  Tab(text: 'Admin / Owner'),
                ],
              ),
              SizedBox(
                height: 400,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCustomerLogin(),
                    _buildAdminLogin(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
