import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Dark theme
  static const darkBg = Color(0xFF0A0A0A);
  static const darkSurface = Color(0xFF141008);
  static const darkSurface2 = Color(0xFF1C1710);
  static const darkSurface3 = Color(0xFF252018);
  static const darkText = Color(0xFFF4F1EA);
  static const darkTextMuted = Color(0xFF8A8680);
  static const darkTextDim = Color(0xFF4A4640);
  static const darkBorder = Color(0xFF2A2520);
  static const darkBorderStrong = Color(0xFF3A3530);

  // Light theme
  static const lightBg = Color(0xFFF6F2E8);
  static const lightSurface = Color(0xFFEEEAE0);
  static const lightSurface2 = Color(0xFFE6E2D8);
  static const lightSurface3 = Color(0xFFDEDAD0);
  static const lightText = Color(0xFF0A0A0A);
  static const lightTextMuted = Color(0xFF6A6660);
  static const lightTextDim = Color(0xFFAAAA98);
  static const lightBorder = Color(0xFFD8D4CA);
  static const lightBorderStrong = Color(0xFFC8C4BA);

  // Accent (gold)
  static const accentDark = Color(0xFFD4AF6A);
  static const accentLight = Color(0xFF6E5320);
  static const accentInkDark = Color(0xFF0A0A0A);
  static const accentInkLight = Color(0xFFF4F1EA);
  static const accentSoftDark = Color(0x1AD4AF6A);
  static const accentSoftLight = Color(0x1A6E5320);

  // Semantic
  static const success = Color(0xFF5A9E6A);
  static const danger = Color(0xFFB85050);
  static const info = Color(0xFF5A7EA0);
  static const scrim = Color(0x80000000);
}

class AppTheme {
  static TextTheme _buildTextTheme(Color textColor) {
    final serif = GoogleFonts.cormorantGaramondTextTheme().apply(
      bodyColor: textColor,
      displayColor: textColor,
    );
    return serif;
  }

  static ThemeData dark() {
    const accent = AppColors.accentDark;
    const bg = AppColors.darkBg;
    const text = AppColors.darkText;

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        onPrimary: AppColors.accentInkDark,
        surface: AppColors.darkSurface,
        onSurface: text,
        error: AppColors.danger,
      ),
      textTheme: _buildTextTheme(text),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dividerColor: AppColors.darkBorder,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: accent),
        ),
        hintStyle: const TextStyle(color: AppColors.darkTextMuted),
      ),
    );
  }

  static ThemeData light() {
    const accent = AppColors.accentLight;
    const bg = AppColors.lightBg;
    const text = AppColors.lightText;

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.light(
        primary: accent,
        onPrimary: AppColors.accentInkLight,
        surface: AppColors.lightSurface,
        onSurface: text,
        error: AppColors.danger,
      ),
      textTheme: _buildTextTheme(text),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dividerColor: AppColors.lightBorder,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: accent),
        ),
        hintStyle: const TextStyle(color: AppColors.lightTextMuted),
      ),
    );
  }
}

class AppTextStyles {
  static TextStyle cormorant({
    double size = 16,
    FontWeight weight = FontWeight.w400,
    FontStyle style = FontStyle.normal,
    Color? color,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.cormorantGaramond(
        fontSize: size,
        fontWeight: weight,
        fontStyle: style,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle cormorantSC({
    double size = 11,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
  }) =>
      GoogleFonts.cormorantSc(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  static TextStyle mono({
    double size = 12,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
  }) =>
      GoogleFonts.ibmPlexMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );
}
