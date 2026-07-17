import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// A lower-priority button style for actions that shouldn't visually
// compete with the primary yellow ElevatedButton — plain text with a
// subtle grey background, used for "Cancel", "Skip", "Not now" style actions.
class AppSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color textColor;

  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.textColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.black3,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14)),
      ),
    );
  }
}