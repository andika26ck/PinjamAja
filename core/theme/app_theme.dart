import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final background = isDark ? AppColors.backgroundDark : AppColors.background;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final inputFill = isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primaryBlue,
      onPrimary: Colors.white,
      secondary: AppColors.secondaryGreen,
      onSecondary: Colors.white,
      error: AppColors.dangerRed,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
    );

    // Heading: Poppins. Body: Inter.
    final headingTextTheme = GoogleFonts.poppinsTextTheme();
    final bodyTextTheme = GoogleFonts.interTextTheme();

    final textTheme = bodyTextTheme
        .copyWith(
          displayLarge: headingTextTheme.displayLarge,
          displayMedium: headingTextTheme.displayMedium,
          displaySmall: headingTextTheme.displaySmall,
          headlineLarge: headingTextTheme.headlineLarge,
          headlineMedium: headingTextTheme.headlineMedium,
          headlineSmall: headingTextTheme.headlineSmall,
          titleLarge: headingTextTheme.titleLarge,
          titleMedium: headingTextTheme.titleMedium,
          titleSmall: headingTextTheme.titleSmall,
        )
        .apply(bodyColor: textPrimary, displayColor: textPrimary);

    final radius12 = BorderRadius.circular(12);
    final radius16 = BorderRadius.circular(16);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      dividerColor: border,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: radius12, borderSide: BorderSide.none),
        enabledBorder:
            OutlineInputBorder(borderRadius: radius12, borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius12,
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius12,
          borderSide: const BorderSide(color: AppColors.dangerRed, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius12,
          borderSide: const BorderSide(color: AppColors.dangerRed, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primaryBlue.withValues(alpha: 0.4),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: radius12),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      // CardThemeData (bukan CardTheme) — sejak Flutter 3.27,
      // ThemeData.cardTheme bertipe CardThemeData.
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: radius16, side: BorderSide(color: border)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1),
    );
  }
}
