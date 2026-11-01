import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF112338);
  static const Color darkNav = Color(0xFF091624);
  static const Color surfaceCard = Color(0xFF1F3550);
  static const Color surfaceSecondary = Color(0xFF2A4365);
  static const Color border = Color(0xFF3B5B82);
  static const Color primary = Color(0xFFFF9500); // Yesplay Orange
  static const Color accentYellow = Color(0xFFFFCC00); // Yellow
  static const Color accentLive = Color(0xFFFF3B30);
  static const Color accentRose = accentLive; // LIVE red
  static const Color textMain = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0B4C8);
  static const Color buttonText = Color(0xFFFFFFFF);

  // Compatibility getters
  static const Color surface = surfaceCard;
  static const Color surfaceElevated = surfaceSecondary;
  static const Color surfaceBorder = border;
  static const Color textPrimary = textMain;
  static const Color textMuted = textSecondary;
  static const Color secondary = primary;
  static const Color darkNavy = darkNav;
  static const Color decorStripes = border;

  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  static const double buttonHeight = 48.0;
  static const double screenPadding = 16.0;

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withAlpha(20),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get neonGlow => [
        BoxShadow(
          color: primary.withAlpha(50),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ];

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accentYellow,
        surface: surfaceCard,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: buttonText,
          elevation: 0,
          minimumSize: const Size(0, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  static ThemeData get darkTheme => theme;
  static ThemeData get lightTheme => theme;
}
