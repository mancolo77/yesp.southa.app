import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Olimp.bet Signature Brand Colors
  static const Color primary = Color(0xFFE51B24); // Signature Olimp Red
  static const Color primaryDark = Color(0xFFB51019); // Deep Crimson
  static const Color primaryLight = Color(0xFFFF333D); // Vivid Red
  static const Color secondary = Color(0xFFF5BA31); // Olimp Gold / Amber
  static const Color goldDark = Color(0xFFD49A1A);
  static const Color burgundy = Color(0xFF38080E); // Deep Luxury Burgundy
  static const Color burgundyLight = Color(0xFF520E17);

  // Status & Utility Colors
  static const Color accentGreen = Color(0xFF10B981); // Success Emerald
  static const Color accentRose = Color(0xFFEF4444); // Error / Danger
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentGold = Color(0xFFF5BA31);

  // Dark Theme Background Surfaces (Olimp.bet obsidian / charcoal)
  static const Color background = Color(0xFF0F0F12); // Deep Obsidian
  static const Color surface = Color(0xFF17171C); // Dark Slate Surface
  static const Color surfaceCard = Color(0xFF1F2026); // Elevated Card Surface
  static const Color surfaceElevated = Color(0xFF262730); // Higher Elevation
  static const Color surfaceBorder = Color(0xFF2E303A); // Crisp Card Border

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // Pure White
  static const Color textSecondary = Color(0xFF9EA3AE); // Cool Silver Grey
  static const Color textMuted = Color(0xFF6B7280); // Muted Charcoal Grey

  // Signature Olimp Gradients
  static const LinearGradient redGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient burgundyGradient = LinearGradient(
    colors: [Color(0xFF38080E), Color(0xFF1A0407)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF5BA31), Color(0xFFD49A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF22232B), Color(0xFF1B1B22)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Box Shadows
  static List<BoxShadow> get redGlow => [
        BoxShadow(
          color: primary.withAlpha(70),
          blurRadius: 18,
          spreadRadius: 2,
        ),
      ];

  static List<BoxShadow> get goldGlow => [
        BoxShadow(
          color: secondary.withAlpha(60),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ];

  static List<BoxShadow> get neonGlow => redGlow;

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: accentRose,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        elevation: 8,
      ),
    );
  }
}
