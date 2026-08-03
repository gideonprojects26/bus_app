import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';

class ThemeProvider with ChangeNotifier {
  bool _isLightMode = false;

  bool get isLightMode => _isLightMode;

  Color get background => _isLightMode ? AppColors.lightBackground : AppColors.darkBackground;
  Color get surface => _isLightMode ? AppColors.lightSurface : AppColors.darkSurface;
  Color get surfaceElevated => _isLightMode ? AppColors.lightSurfaceElevated : AppColors.darkSurfaceElevated;
  Color get textPrimary => _isLightMode ? AppColors.lightTextPrimary : AppColors.darkTextPrimary;

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