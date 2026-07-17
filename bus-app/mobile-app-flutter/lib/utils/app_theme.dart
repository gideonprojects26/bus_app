import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get theme {
    final baseTextTheme = GoogleFonts.poppinsTextTheme();

    return ThemeData(
      scaffoldBackgroundColor: AppColors.black,
      primaryColor: AppColors.yellow,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.yellow,
        secondary: AppColors.red,
        surface: AppColors.black,
      ),
      // Applies Poppins across all default text styles (headings, body,
      // labels) so the whole app shares one consistent typeface instead
      // of falling back to the platform default (Roboto on Android).
      textTheme: baseTextTheme.apply(
        bodyColor: AppColors.white,
        displayColor: AppColors.white,
      ).copyWith(
        // A bold, rounded headline style for page titles (e.g. "Activity",
        // "Profile"), matching the punchy large-header look used across
        // the reference design.
        headlineMedium: GoogleFonts.poppins(
          color: AppColors.white,
          fontSize: 30,
          fontWeight: FontWeight.w800,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.yellow,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.yellow,
          foregroundColor: AppColors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.yellow, width: 1.4),
        ),
        hintStyle: GoogleFonts.poppins(color: AppColors.grey, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      useMaterial3: true,
    );
  }
}