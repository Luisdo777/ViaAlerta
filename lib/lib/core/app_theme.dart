import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cores extraídas do protótipo do Figma.
class AppColors {
  static const navy = Color(0xFF152548);
  static const background = Color(0xFF1B1C1E);
  static const surface = Color(0xFF1F2022);
  static const border = Color(0xFF3A3C40);
  static const orange = Color(0xFFC2500A);
  static const orangeText = Color(0xFFFF6B2C);
  static const lightBlue = Color(0xFF8DB7F0);
  static const textMuted = Color(0xFF9A9CA1);
  static const green = Color(0xFF34D27B);
  static const amber = Color(0xFFF59E0B);
  static const blue = Color(0xFF3B82F6);
  static const red = Color(0xFFEF4444);
}

class AppTheme {
  static ThemeData dark() {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    final textTheme = GoogleFonts.nunitoTextTheme(base.textTheme).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.orange,
        secondary: AppColors.lightBlue,
        surface: AppColors.surface,
        error: AppColors.red,
      ),
      textTheme: textTheme,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}
