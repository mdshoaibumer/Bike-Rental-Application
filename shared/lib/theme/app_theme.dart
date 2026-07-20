import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Color Palette
  static const Color _primaryBlue = Color(0xFF0F62FE); // Deep Royal Blue
  static const Color _electricBlue = Color(0xFF0077FF); // Secondary Blue
  static const Color _accentOrange = Color(0xFFFF8C42); // Premium Orange CTA
  static const Color _successGreen = Color(0xFF10B981); // Emerald Green
  static const Color _warningAmber = Color(0xFFF59E0B); // Amber
  static const Color _errorRed = Color(0xFFDC2626); // Rich Red
  static const Color _secondaryAccent = Color(0xFF001D6C); // Deep accent
  
  // Surfaces
  static const Color _surfaceLight = Color(0xFFF8FAFC);
  static const Color _surfaceDark = Color(0xFF0F1419);
  static const Color _cardLight = Colors.white;
  static const Color _cardDark = Color(0xFF1E1E1E);
  
  // Glass Morphism & Overlays
  static const Color _glassLight = Color(0xFFFFFFFF);
  static const Color _glassDark = Color(0xFF1E1E1E);
  
  // Semantic Colors
  static const Color _textPrimary = Color(0xFF1F2937);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _textTertiary = Color(0xFF9CA3AF);
  static const Color _textPrimaryDark = Color(0xFFF3F4F6);
  static const Color _textSecondaryDark = Color(0xFFD1D5DB);
  static const Color _textTertiaryDark = Color(0xFF9CA3AF);

  // Premium Shadow System
  static const BoxShadow shadowSm = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  static const BoxShadow shadowMd = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const BoxShadow shadowLg = BoxShadow(
    color: Color(0x15000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  static const BoxShadow shadowXl = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 16,
    offset: Offset(0, 8),
  );

  static const List<BoxShadow> cardShadow = [shadowMd];
  static const List<BoxShadow> elevatedShadow = [shadowLg];
  static const List<BoxShadow> dialogShadow = [shadowXl];

  static TextTheme _buildTextTheme(TextTheme base) {
    return GoogleFonts.interTextTheme(base).copyWith(
      displayLarge: GoogleFonts.outfit(
        textStyle: base.displayLarge?.copyWith(
          fontSize: 56,
          height: 1.2,
        ),
        fontWeight: FontWeight.bold,
        letterSpacing: -1.0,
      ),
      displayMedium: GoogleFonts.outfit(
        textStyle: base.displayMedium?.copyWith(
          fontSize: 45,
          height: 1.25,
        ),
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.outfit(
        textStyle: base.displaySmall?.copyWith(
          fontSize: 36,
          height: 1.3,
        ),
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: GoogleFonts.outfit(
        textStyle: base.headlineLarge?.copyWith(
          fontSize: 32,
          height: 1.4,
        ),
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: GoogleFonts.outfit(
        textStyle: base.headlineMedium?.copyWith(
          fontSize: 28,
          height: 1.4,
        ),
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.outfit(
        textStyle: base.headlineSmall?.copyWith(
          fontSize: 24,
          height: 1.5,
        ),
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.outfit(
        textStyle: base.titleLarge?.copyWith(
          fontSize: 20,
          height: 1.5,
        ),
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.inter(
        textStyle: base.titleMedium?.copyWith(
          fontSize: 16,
          height: 1.5,
        ),
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.inter(
        textStyle: base.titleSmall?.copyWith(
          fontSize: 14,
          height: 1.5,
        ),
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.inter(
        textStyle: base.bodyLarge?.copyWith(
          fontSize: 16,
          height: 1.6,
        ),
        letterSpacing: 0.2,
      ),
      bodyMedium: GoogleFonts.inter(
        textStyle: base.bodyMedium?.copyWith(
          fontSize: 14,
          height: 1.6,
        ),
        letterSpacing: 0.1,
      ),
      bodySmall: GoogleFonts.inter(
        textStyle: base.bodySmall?.copyWith(
          fontSize: 12,
          height: 1.5,
        ),
        letterSpacing: 0.1,
      ),
      labelLarge: GoogleFonts.inter(
        textStyle: base.labelLarge?.copyWith(
          fontSize: 14,
          height: 1.4,
        ),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      labelMedium: GoogleFonts.inter(
        textStyle: base.labelMedium?.copyWith(
          fontSize: 12,
          height: 1.4,
        ),
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      ),
      labelSmall: GoogleFonts.inter(
        textStyle: base.labelSmall?.copyWith(
          fontSize: 11,
          height: 1.4,
        ),
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryBlue,
        primary: _primaryBlue,
        secondary: _electricBlue,
        tertiary: _accentOrange,
        surface: _surfaceLight,
        surfaceVariant: _cardLight,
        error: _errorRed,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: _surfaceLight,
      textTheme: _buildTextTheme(base.textTheme).apply(
        bodyColor: _textPrimary,
        displayColor: _textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: _textPrimary),
        titleTextStyle: TextStyle(
          color: _textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Outfit',
        ),
      ),
      cardTheme: CardTheme(
        color: _cardLight,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: _primaryBlue, width: 2),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryBlue,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _errorRed, width: 2),
        ),
        filled: true,
        fillColor: _surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(
          color: _textTertiary,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: _textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: _cardLight,
        selectedItemColor: _primaryBlue,
        unselectedItemColor: _textTertiary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceLight,
        selectedColor: _primaryBlue,
        disabledColor: _textTertiary.withValues(alpha: 0.12),
        labelStyle: const TextStyle(
          color: _textPrimary,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        secondary: _electricBlue,
        tertiary: _accentOrange,
        surface: _surfaceDark,
        surfaceVariant: _cardDark,
        error: _errorRed,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: _surfaceDark,
      textTheme: _buildTextTheme(base.textTheme).apply(
        bodyColor: _textPrimaryDark,
        displayColor: _textPrimaryDark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: _textPrimaryDark),
        titleTextStyle: TextStyle(
          color: _textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Outfit',
        ),
      ),
      cardTheme: CardTheme(
        color: _cardDark,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: _primaryBlue, width: 2),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryBlue,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _errorRed, width: 2),
        ),
        filled: true,
        fillColor: _cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(
          color: _textTertiaryDark,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: _textSecondaryDark,
          fontWeight: FontWeight.w500,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: _cardDark,
        selectedItemColor: _primaryBlue,
        unselectedItemColor: _textTertiaryDark,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Color(0xFF2A2A2A),
        selectedColor: _primaryBlue,
        disabledColor: _textTertiaryDark.withValues(alpha: 0.12),
        labelStyle: const TextStyle(
          color: _textPrimaryDark,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [_primaryBlue, _electricBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [_accentOrange, Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [_successGreen, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [_surfaceLight, Color(0xFFF0F4F8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass Morphism Gradient
  static LinearGradient glassGradient(bool isDark) {
    return LinearGradient(
      colors: [
        isDark ? _glassDark.withValues(alpha: 0.9) : _glassLight.withValues(alpha: 0.9),
        isDark ? _glassDark.withValues(alpha: 0.7) : _glassLight.withValues(alpha: 0.7),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Semantic Color Constants
  static const Map<String, Color> semanticColors = {
    'success': _successGreen,
    'warning': _warningAmber,
    'error': _errorRed,
    'info': _primaryBlue,
  };
}
