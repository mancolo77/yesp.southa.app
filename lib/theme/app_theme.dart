import 'package:flutter/material.dart';

class AppTheme {
  // ПАЛИТРА ПО ТЗ (YesP / Дневник спортивной активности):
  // • #FFFFFF — основной фон и карточки.
  // • #F3F5F7 — фон секций и полей ввода.
  // • #102638 — заголовки, нижняя навигация и контрастные блоки.
  // • #1C4562 — дополнительные синие поверхности.
  // • #F58224 — основной оранжевый акцент: кнопки и активные элементы.
  // • #A94708 — текстовые акценты на светлом фоне.
  // • #C7CCD6 — декоративные диагональные полосы.
  // • #536170 — второстепенный текст.
  // • #E1E5EA — разделители и контуры.
  // • #347A36 — отметки выполненных занятий.
  // На оранжевых кнопках использовать текст #102638, на тёмно-синих поверхностях — #FFFFFF.

  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceSection = Color(0xFFF3F5F7);
  static const Color darkNavy = Color(0xFF102638);
  static const Color navySurface = Color(0xFF1C4562);
  static const Color primary = Color(0xFFF58224); // Оранжевый акцент
  static const Color textAccent = Color(0xFFA94708);
  static const Color decorStripes = Color(0xFFC7CCD6);
  static const Color textSecondary = Color(0xFF536170);
  static const Color border = Color(0xFFE1E5EA);
  static const Color completedGreen = Color(0xFF347A36);
  static const Color onPrimary = Color(0xFF102638);

  // Совместимость
  static const Color surface = surfaceCard;
  static const Color surfaceElevated = surfaceSection;
  static const Color surfaceBorder = border;
  static const Color textPrimary = darkNavy;
  static const Color textMuted = textSecondary;
  static const Color secondary = darkNavy;
  static const Color accentGreen = completedGreen;
  static const Color accentRose = Color(0xFFEF4444);
  static const Color accentGold = primary;
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color burgundy = darkNavy;
  static const Color burgundyLight = navySurface;

  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  static const double screenPadding = 16.0;
  static const double buttonHeight = 48.0;

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withAlpha(12),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ];

  static List<BoxShadow> get orangeGlow => [
        BoxShadow(
          color: primary.withAlpha(60),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ];

  static List<BoxShadow> get neonGlow => orangeGlow;
  static List<BoxShadow> get redGlow => orangeGlow;
  static List<BoxShadow> get goldGlow => orangeGlow;

  static const LinearGradient heroGradient = LinearGradient(
    colors: [darkNavy, navySurface],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [surfaceCard, surfaceSection],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient redGradient = LinearGradient(
    colors: [primary, textAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = redGradient;
  static const LinearGradient burgundyGradient = heroGradient;

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: darkNavy,
        surface: surfaceCard,
        error: accentRose,
        onPrimary: onPrimary,
        onSurface: darkNavy,
      ),
      fontFamily: null, // Системный шрифт
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: darkNavy),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkNavy),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkNavy),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: darkNavy),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: darkNavy),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: textSecondary),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size(0, buttonHeight),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
          elevation: 0,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkNavy),
        iconTheme: IconThemeData(color: darkNavy),
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}
