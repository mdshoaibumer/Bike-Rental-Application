import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Color Palette
  static const Color _primaryBlue = Color(0xFF0F62FE);
  static const Color _secondaryAccent = Color(0xFF001D6C);
  static const Color _surfaceLight = Color(0xFFF4F7FB);
  static const Color _surfaceDark = Color(0xFF121212);
  static const Color _cardLight = Colors.white;
  static const Color _cardDark = Color(0xFF1E1E1E);

  static TextTheme _buildTextTheme(TextTheme base) {
    return GoogleFonts.interTextTheme(base).copyWith(
      displayLarge: GoogleFonts.outfit(
          textStyle: base.displayLarge, fontWeight: FontWeight.bold, letterSpacing: -1.0),
      displayMedium: GoogleFonts.outfit(
          textStyle: base.displayMedium, fontWeight: FontWeight.bold, letterSpacing: -0.5),
      displaySmall: GoogleFonts.outfit(
          textStyle: base.displaySmall, fontWeight: FontWeight.bold),
      headlineLarge: GoogleFonts.outfit(
          textStyle: base.headlineLarge, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.outfit(
          textStyle: base.headlineMedium, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.outfit(
          textStyle: base.titleLarge, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.inter(
          textStyle: base.titleMedium, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.inter(
          textStyle: base.bodyLarge, letterSpacing: 0.2),
      bodyMedium: GoogleFonts.inter(
          textStyle: base.bodyMedium, letterSpacing: 0.1),
      labelLarge: GoogleFonts.inter(
          textStyle: base.labelLarge, fontWeight: FontWeight.w600, letterSpacing: 0.5),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryBlue,
        primary: _primaryBlue,
        secondary: _secondaryAccent,
        surface: _surfaceLight,
        surfaceVariant: _cardLight,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: _surfaceLight,
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Outfit',
        ),
      ),
      cardTheme: CardTheme(
        color: _cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: _primaryBlue, width: 1.5),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _primaryBlue, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.white,
        selectedItemColor: _primaryBlue,
        unselectedItemColor: Colors.black38,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryBlue,
        primary: _primaryBlue,
        secondary: Colors.blueAccent,
        surface: _surfaceDark,
        surfaceVariant: _cardDark,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: _surfaceDark,
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Outfit',
        ),
      ),
      cardTheme: CardTheme(
        color: _cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: _primaryBlue, width: 1.5),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _primaryBlue, width: 2),
        ),
        filled: true,
        fillColor: _cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: _surfaceDark,
        selectedItemColor: _primaryBlue,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
