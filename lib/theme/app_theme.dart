import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette from Prompt
  static const Color background = Color(0xFFFFFFFF);
  static const Color sectionBg = Color(0xFFF3F5F7);
  static const Color darkNavy = Color(0xFF102638);
  static const Color secondaryBlue = Color(0xFF1C4562);
  static const Color orangeAccent = Color(0xFFF58224);
  static const Color textAccent = Color(0xFFA94708);
  static const Color decorStripes = Color(0xFFC7CCD6);
  static const Color textSecondary = Color(0xFF536170);
  static const Color border = Color(0xFFE1E5EA);
  static const Color statusCompleted = Color(0xFF347A36); // #347A36 completed marks

  // Semantic mappings
  static const Color primary = orangeAccent;
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = sectionBg;
  static const Color textMain = darkNavy;
  static const Color darkNav = darkNavy;
  static const Color accentYellow = orangeAccent;
  static const Color accentRose = Color(0xFFFF3B30);
  static const Color buttonText = darkNavy;

  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  static const double buttonHeight = 48.0;
  static const double screenPadding = 16.0;

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: darkNavy.withAlpha(12),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ];

  static List<BoxShadow> get neonGlow => [
        BoxShadow(
          color: orangeAccent.withAlpha(50),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: orangeAccent,
      colorScheme: const ColorScheme.light(
        primary: orangeAccent,
        secondary: secondaryBlue,
        surface: surfaceCard,
        onPrimary: darkNavy,
        onSurface: darkNavy,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: orangeAccent,
          foregroundColor: darkNavy,
          elevation: 0,
          minimumSize: const Size(0, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkNavy,
        selectedItemColor: orangeAccent,
        unselectedItemColor: Color(0xFF8A99A8),
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      ),
    );
  }

  static ThemeData get theme => lightTheme;
}

class DiaryDiagonalPainter extends CustomPainter {
  final Color stripeColor;
  final double stripeWidth;
  final double gap;

  DiaryDiagonalPainter({
    this.stripeColor = AppTheme.decorStripes,
    this.stripeWidth = 5.0,
    this.gap = 14.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = stripeColor.withAlpha(45)
      ..strokeWidth = stripeWidth
      ..style = PaintingStyle.stroke;

    final step = stripeWidth + gap;
    final total = size.width + size.height;

    for (double x = -size.height; x < total; x += step) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
