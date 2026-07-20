import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/widgets/primary_button.dart';
import 'package:shared/widgets/glass_morphism_container.dart';
import 'package:shared/theme/app_theme.dart';
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
  String? _phoneError;
  String? _otpError;
  String? _adminError;

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
    final mobile = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '').trim();
    setState(() => _phoneError = null);
    
    if (mobile.isEmpty) {
      setState(() => _phoneError = 'Phone number is required');
      return;
    }
    if (mobile.length < 10) {
      setState(() => _phoneError = 'Phone number must be at least 10 digits');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).sendOTP(mobile);
      setState(() {
        _isLoading = false;
        _otpSent = true;
        _phoneError = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('Verification code sent!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _phoneError = 'Failed to send OTP. Please try again.';
      });
    }
  }

  void _handleVerifyOtp() async {
    final mobile = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '').trim();
    final code = _otpController.text.trim();

    setState(() => _otpError = null);

    if (code.isEmpty) {
      setState(() => _otpError = 'Please enter the verification code');
      return;
    }
    if (code.length != 6 || !RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _otpError = 'Code must be exactly 6 digits');
      return;
    }

    setState(() => _isLoading = true);
    try {
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
        setState(() => _otpError = 'Invalid or expired verification code');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _otpError = 'Verification failed. Please try again.';
      });
    }
  }

  void _handlePasswordLogin() async {
    final id = _adminIdController.text.trim();
    final password = _adminPasswordController.text;

    setState(() => _adminError = null);

    if (id.isEmpty) {
      setState(() => _adminError = 'Email or mobile is required');
      return;
    }
    if (password.isEmpty) {
      setState(() => _adminError = 'Password is required');
      return;
    }

    setState(() => _isLoading = true);
    try {
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
        setState(() => _adminError = 'Invalid email/mobile or password');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _adminError = 'Login failed. Please try again.';
      });
    }
  }

  Widget _buildCustomerLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        if (!_otpSent) ...[
          GlassMorphismContainer(
            child: TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                hintText: '+91 9876543210',
                prefixIcon: const Icon(Icons.phone_android_rounded),
                border: InputBorder.none,
                filled: false,
                errorText: null,
              ),
              keyboardType: TextInputType.phone,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              onChanged: (_) => setState(() => _phoneError = null),
            ),
          ),
          if (_phoneError != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _phoneError!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          PrimaryButton(
            text: 'Send Verification Code',
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _handleSendOtp,
            leadingIcon: _isLoading
                ? null
                : const Icon(Icons.phone_forwarded_rounded, color: Colors.white, size: 18),
          ),
        ] else ...[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Column(
              key: ValueKey(_otpSent),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Verification Code',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter the 6-digit code sent to ${_phoneController.text}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme._textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                GlassMorphismContainer(
                  child: TextField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      border: InputBorder.none,
                      filled: false,
                      counterText: '',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 12,
                    ),
                    textAlign: TextAlign.center,
                    onChanged: (_) => setState(() => _otpError = null),
                  ),
                ),
                if (_otpError != null) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _otpError!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                PrimaryButton(
                  text: 'Verify & Login',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleVerifyOtp,
                  leadingIcon: _isLoading
                      ? null
                      : const Icon(Icons.check_circle_outline_rounded,
                          color: Colors.white, size: 18),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _otpSent = false),
                    child: Text(
                      'Change phone number',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme._primaryBlue,
                      ),
                    ),
                  ),
                ),
              ],
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
        const SizedBox(height: 24),
        GlassMorphismContainer(
          child: TextField(
            controller: _adminIdController,
            decoration: InputDecoration(
              labelText: 'Email or Mobile Number',
              hintText: 'admin@bikerental.com',
              prefixIcon: const Icon(Icons.person_outline_rounded),
              border: InputBorder.none,
              filled: false,
            ),
            keyboardType: TextInputType.emailAddress,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            onChanged: (_) => setState(() => _adminError = null),
          ),
        ),
        const SizedBox(height: 20),
        GlassMorphismContainer(
          child: TextField(
            controller: _adminPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              border: InputBorder.none,
              filled: false,
            ),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            onChanged: (_) => setState(() => _adminError = null),
          ),
        ),
        if (_adminError != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 18, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _adminError!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 28),
        PrimaryButton(
          text: 'Login to Dashboard',
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _handlePasswordLogin,
          leadingIcon: _isLoading
              ? null
              : const Icon(Icons.dashboard_rounded, color: Colors.white, size: 18),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Premium Header with Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.electric_moped_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Premium Bike Rentals',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppTheme._primaryBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppTheme._textSecondary,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    tabs: const [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Tab(text: 'Customer'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Tab(text: 'Admin'),
                      ),
                    ],
                  ),
                ),
              ),
              // Tab View
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: SizedBox(
                  height: 420,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCustomerLogin(),
                      _buildAdminLogin(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
