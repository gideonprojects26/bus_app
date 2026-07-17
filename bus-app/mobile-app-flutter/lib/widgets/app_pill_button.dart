import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// An outlined, pill-shaped button used for secondary calls-to-action,
// matching the "Book Scheduled Trip" style seen in the reference design:
// a bordered rounded button with an optional trailing icon.
class AppPillButton extends StatelessWidget {
  final String label;
  final IconData? trailingIcon;
  final VoidCallback onTap;
  final Color color;

  const AppPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.trailingIcon,
    this.color = AppColors.yellow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 1.2)),
                child: Icon(trailingIcon, color: color, size: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}