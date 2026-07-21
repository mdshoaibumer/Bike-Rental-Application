import 'package:flutter_test/flutter_test.dart';

/// Tests for the validation logic used throughout the app.
/// The validation is inline in LoginScreen, so we extract and test the rules:
/// - Phone: must be non-empty, digits only, at least 10 digits
/// - OTP: must be non-empty, exactly 6 digits
/// - Admin login: email/mobile and password must be non-empty

// Validation functions extracted from login_screen.dart logic
String? validatePhone(String input) {
  final mobile = input.replaceAll(RegExp(r'[^\d]'), '').trim();
  if (mobile.isEmpty) return 'Phone number is required';
  if (mobile.length < 10) return 'Phone number must be at least 10 digits';
  return null;
}

String? validateOtp(String input) {
  final code = input.trim();
  if (code.isEmpty) return 'Please enter the verification code';
  if (code.length != 6 || !RegExp(r'^\d{6}$').hasMatch(code)) {
    return 'Code must be exactly 6 digits';
  }
  return null;
}

String? validateAdminLogin(String id, String password) {
  if (id.trim().isEmpty) return 'Email or mobile is required';
  if (password.isEmpty) return 'Password is required';
  return null;
}

void main() {
  group('Phone Validation', () {
    test('empty phone returns error', () {
      expect(validatePhone(''), 'Phone number is required');
    });

    test('whitespace-only phone returns error', () {
      expect(validatePhone('   '), 'Phone number is required');
    });

    test('phone with less than 10 digits returns error', () {
      expect(validatePhone('12345'), 'Phone number must be at least 10 digits');
    });

    test('phone with exactly 10 digits is valid', () {
      expect(validatePhone('9876543210'), isNull);
    });

    test('phone with more than 10 digits is valid', () {
      expect(validatePhone('919876543210'), isNull);
    });

    test('phone with formatting characters strips non-digits', () {
      expect(validatePhone('+91 987-654-3210'), isNull);
    });

    test('phone with only non-digit characters fails', () {
      expect(validatePhone('abc'), 'Phone number is required');
    });
  });

  group('OTP Validation', () {
    test('empty OTP returns error', () {
      expect(validateOtp(''), 'Please enter the verification code');
    });

    test('OTP with less than 6 digits returns error', () {
      expect(validateOtp('12345'), 'Code must be exactly 6 digits');
    });

    test('OTP with more than 6 digits returns error', () {
      expect(validateOtp('1234567'), 'Code must be exactly 6 digits');
    });

    test('OTP with non-numeric characters returns error', () {
      expect(validateOtp('12345a'), 'Code must be exactly 6 digits');
    });

    test('valid 6-digit OTP passes', () {
      expect(validateOtp('123456'), isNull);
    });

    test('OTP with leading/trailing spaces is trimmed', () {
      expect(validateOtp(' 123456 '), isNull);
    });
  });

  group('Admin Login Validation', () {
    test('empty email returns error', () {
      expect(validateAdminLogin('', 'password'), 'Email or mobile is required');
    });

    test('empty password returns error', () {
      expect(validateAdminLogin('admin@test.com', ''), 'Password is required');
    });

    test('both empty returns email error first', () {
      expect(validateAdminLogin('', ''), 'Email or mobile is required');
    });

    test('valid email and password passes', () {
      expect(validateAdminLogin('admin@bikerental.com', 'admin123'), isNull);
    });

    test('whitespace-only email returns error', () {
      expect(validateAdminLogin('   ', 'pass'), 'Email or mobile is required');
    });
  });
}
