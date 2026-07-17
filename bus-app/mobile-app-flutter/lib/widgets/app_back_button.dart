import 'package:flutter/material.dart';
import '../utils/app_colors.dart';


// Custom back button that displays a plain "<" character instead of
// the default arrow icon, used as the `leading` widget on AppBars
// throughout the app.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.pop(context),
      icon: const Text(
        '<',
        style: TextStyle(
          color: AppColors.yellow,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}