import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/network/api_client.dart';
import 'package:shared/storage/secure_storage.dart';

// Core providers
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient.instance);
final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

// Auth state
enum AuthStatus { initial, authenticated, unauthenticated, loading }
enum AppRole { customer, admin, staff }

class AuthState {
  final AuthStatus status;
  final String? error;
  final Map<String, dynamic>? user;
  final AppRole? role;

  const AuthState({
    this.status = AuthStatus.initial,
    this.error,
    this.user,
    this.role,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? error,
    Map<String, dynamic>? user,
    AppRole? role,
  }) {
    return AuthState(
      status: status ?? this.status,
      error: error,
      user: user ?? this.user,
      role: role ?? this.role,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;
  final SecureStorage _storage;

  AuthNotifier(this._apiClient, this._storage) : super(const AuthState());

  Future<void> checkAuth() async {
    final token = await _storage.getToken();
    final roleStr = await _storage.getRole();
    
    if (token != null && token.isNotEmpty) {
      AppRole role = AppRole.customer;
      if (roleStr == 'ADMIN') role = AppRole.admin;
      else if (roleStr == 'STAFF') role = AppRole.staff;
      
      state = state.copyWith(status: AuthStatus.authenticated, role: role);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> sendOTP(String mobile) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    // DEMO MODE CHECK
    if (mobile == '9876543210') {
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      await _apiClient.dio.post('/auth/send-otp', data: {'mobile': mobile});
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: 'Failed to send OTP');
    }
  }

  Future<bool> verifyOTP(String mobile, String code) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    // DEMO MODE CHECK
    if (mobile == '9876543210' && code == '123456') {
      await Future.delayed(const Duration(seconds: 1));
      await _storage.saveToken('demo_token');
      await _storage.saveRole('CUSTOMER');
      state = state.copyWith(
        status: AuthStatus.authenticated,
        role: AppRole.customer,
      );
      return true;
    }

    try {
      final response = await _apiClient.dio.post('/auth/verify-otp', data: {
        'mobile': mobile,
        'code': code,
      });
      final data = response.data;
      await _storage.saveToken(data['access_token']);
      await _storage.saveRefreshToken(data['refresh_token']);
      
      final roleStr = data['role'] ?? 'CUSTOMER';
      await _storage.saveRole(roleStr);
      
      AppRole role = AppRole.customer;
      if (roleStr == 'ADMIN') role = AppRole.admin;
      else if (roleStr == 'STAFF') role = AppRole.staff;

      state = state.copyWith(status: AuthStatus.authenticated, role: role);
      return true;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: 'Invalid OTP');
      return false;
    }
  }

  Future<bool> loginWithPassword(String emailOrMobile, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    // DEMO MODE CHECK
    if (emailOrMobile == 'admin@bikerental.com' && password == 'admin123') {
      await Future.delayed(const Duration(seconds: 1));
      await _storage.saveToken('demo_admin_token');
      await _storage.saveRole('ADMIN');
      state = state.copyWith(
        status: AuthStatus.authenticated,
        role: AppRole.admin,
      );
      return true;
    }

    try {
      final response = await _apiClient.dio.post('/auth/login', data: {
        'email_or_mobile': emailOrMobile,
        'password': password,
      });
      final data = response.data;
      await _storage.saveToken(data['access_token']);
      await _storage.saveRefreshToken(data['refresh_token']);
      
      final roleStr = data['role'] ?? 'ADMIN';
      await _storage.saveRole(roleStr);
      
      AppRole role = AppRole.admin;
      if (roleStr == 'CUSTOMER') role = AppRole.customer;
      else if (roleStr == 'STAFF') role = AppRole.staff;

      state = state.copyWith(status: AuthStatus.authenticated, role: role);
      return true;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: 'Invalid Credentials');
      return false;
    }
  }

  Future<void> logout() async {
    final refreshToken = await _storage.getRefreshToken();
    try {
      await _apiClient.dio.post('/auth/logout', data: {'refresh_token': refreshToken});
    } catch (_) {}
    await _storage.deleteAll();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(apiClientProvider), ref.read(secureStorageProvider));
});
