import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';

// Holds the current theme mode and exposes semantic color ROLES
// (background, surface, textPrimary) that resolve to different actual
// colors depending on whether light or dark mode is active. Any
// widget that wants theme-aware color must read these through
// Provider (context.watch<ThemeProvider>()) rather than a static
// const — that's the tradeoff for making theme switching possible.
class ThemeProvider with ChangeNotifier {
  bool _isLightMode = false;

  bool get isLightMode => _isLightMode;

  Color get background => _isLightMode ? AppColors.lightBackground : AppColors.darkBackground;
  Color get surface => _isLightMode ? AppColors.lightSurface : AppColors.darkSurface;
  Color get surfaceElevated => _isLightMode ? AppColors.lightSurfaceElevated : AppColors.darkSurfaceElevated;
  Color get textPrimary => _isLightMode ? AppColors.lightTextPrimary : AppColors.darkTextPrimary;

  // Text/icons sitting ON TOP of a yellow surface (buttons, badges)
  // always need to stay dark for contrast, regardless of overall
  // theme — this is intentionally NOT theme-dependent.
  Color get textOnAccent => AppColors.darkBackground;

  Future<void> loadSavedPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isLightMode = prefs.getBool('is_light_mode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isLightMode = !_isLightMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_light_mode', _isLightMode);
  }
}