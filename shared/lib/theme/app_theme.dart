import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Color Palette
  static const Color primaryBlue = Color(0xFF0F62FE); // Deep Royal Blue
  static const Color electricBlue = Color(0xFF0077FF); // Secondary Blue
  static const Color accentOrange = Color(0xFFFF8C42); // Premium Orange CTA
  static const Color successGreen = Color(0xFF10B981); // Emerald Green
  static const Color warningAmber = Color(0xFFF59E0B); // Amber
  static const Color errorRed = Color(0xFFDC2626); // Rich Red
  static const Color secondaryAccent = Color(0xFF001D6C); // Deep accent
  
  // Surfaces
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color surfaceDark = Color(0xFF0F1419);
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E1E1E);
  
  // Glass Morphism & Overlays
  static const Color glassLight = Color(0xFFFFFFFF);
  static const Color glassDark = Color(0xFF1E1E1E);
  
  // Semantic Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textPrimaryDark = Color(0xFFF3F4F6);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  static const Color textTertiaryDark = Color(0xFF9CA3AF);

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
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: electricBlue,
        tertiary: accentOrange,
        surface: surfaceLight,
        surfaceVariant: cardLight,
        error: errorRed,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: surfaceLight,
      textTheme: _buildTextTheme(base.textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Outfit',
        ),
      ),
      cardTheme: CardTheme(
        color: cardLight,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryBlue,
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
          side: const BorderSide(color: primaryBlue, width: 2),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
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
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: const TextStyle(
          color: textTertiary,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: cardLight,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLight,
        selectedColor: primaryBlue,
        disabledColor: textTertiary.withOpacity(0.12),
        labelStyle: const TextStyle(
          color: textPrimary,
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
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: electricBlue,
        tertiary: accentOrange,
        surface: surfaceDark,
        surfaceVariant: cardDark,
        error: errorRed,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: surfaceDark,
      textTheme: _buildTextTheme(base.textTheme).apply(
        bodyColor: textPrimaryDark,
        displayColor: textPrimaryDark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: textPrimaryDark),
        titleTextStyle: const TextStyle(
          color: textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Outfit',
        ),
      ),
      cardTheme: CardTheme(
        color: cardDark,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryBlue,
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
          side: const BorderSide(color: primaryBlue, width: 2),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
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
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        filled: true,
        fillColor: cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: const TextStyle(
          color: textTertiaryDark,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: textSecondaryDark,
          fontWeight: FontWeight.w500,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: cardDark,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textTertiaryDark,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2A2A2A),
        selectedColor: primaryBlue,
        disabledColor: textTertiaryDark.withOpacity(0.12),
        labelStyle: const TextStyle(
          color: textPrimaryDark,
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
    colors: [primaryBlue, electricBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentOrange, Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [successGreen, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surfaceLight, Color(0xFFF0F4F8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass Morphism Gradient
  static LinearGradient glassGradient(bool isDark) {
    return LinearGradient(
      colors: [
        isDark ? glassDark.withOpacity(0.9) : glassLight.withOpacity(0.9),
        isDark ? glassDark.withOpacity(0.7) : glassLight.withOpacity(0.7),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Semantic Color Constants
  static const Map<String, Color> semanticColors = {
    'success': successGreen,
    'warning': warningAmber,
    'error': errorRed,
    'info': primaryBlue,
  };
}
