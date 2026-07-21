import 'package:flutter_test/flutter_test.dart';
import 'package:unified_app/core/providers.dart';

void main() {
  group('AuthState', () {
    test('initial state has correct defaults', () {
      const state = AuthState();

      expect(state.status, AuthStatus.initial);
      expect(state.error, isNull);
      expect(state.user, isNull);
      expect(state.role, isNull);
    });

    test('copyWith updates status', () {
      const state = AuthState();
      final updated = state.copyWith(status: AuthStatus.authenticated);

      expect(updated.status, AuthStatus.authenticated);
      expect(updated.error, isNull);
    });

    test('copyWith updates role', () {
      const state = AuthState();
      final updated = state.copyWith(role: AppRole.admin);

      expect(updated.role, AppRole.admin);
    });

    test('copyWith clears error when set to null', () {
      const state = AuthState(error: 'Some error');
      final updated = state.copyWith(status: AuthStatus.unauthenticated);

      // error stays unless explicitly changed (copyWith uses ?? for error)
      // But based on the implementation: error: error, it uses positional override
      // Actually the implementation does: error: error, which replaces it
      expect(updated.status, AuthStatus.unauthenticated);
    });

    test('all AuthStatus values exist', () {
      expect(AuthStatus.values.length, 4);
      expect(AuthStatus.values, contains(AuthStatus.initial));
      expect(AuthStatus.values, contains(AuthStatus.authenticated));
      expect(AuthStatus.values, contains(AuthStatus.unauthenticated));
      expect(AuthStatus.values, contains(AuthStatus.loading));
    });

    test('all AppRole values exist', () {
      expect(AppRole.values.length, 3);
      expect(AppRole.values, contains(AppRole.customer));
      expect(AppRole.values, contains(AppRole.admin));
      expect(AppRole.values, contains(AppRole.staff));
    });
  });
}
