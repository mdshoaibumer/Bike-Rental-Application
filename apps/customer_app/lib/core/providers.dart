import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/network/api_client.dart';
import 'package:shared/storage/secure_storage.dart';

// Core providers
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

// Auth state
enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final String? error;
  final Map<String, dynamic>? user;

  const AuthState({
    this.status = AuthStatus.initial,
    this.error,
    this.user,
  });

  AuthState copyWith({AuthStatus? status, String? error, Map<String, dynamic>? user}) {
    return AuthState(
      status: status ?? this.status,
      error: error,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;
  final SecureStorage _storage;

  AuthNotifier(this._apiClient, this._storage) : super(const AuthState());

  Future<void> checkAuth() async {
    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      state = state.copyWith(status: AuthStatus.authenticated);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> sendOTP(String mobile) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _apiClient.dio.post('/auth/send-otp', data: {'mobile': mobile});
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: 'Failed to send OTP');
    }
  }

  Future<bool> verifyOTP(String mobile, String code) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final response = await _apiClient.dio.post('/auth/verify-otp', data: {
        'mobile': mobile,
        'code': code,
      });
      final data = response.data;
      await _storage.saveToken(data['access_token']);
      await _storage.saveRefreshToken(data['refresh_token']);
      state = state.copyWith(status: AuthStatus.authenticated);
      return true;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: 'Invalid OTP');
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
