import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'app_card_shadow.dart';

class QuickActionButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.imagePath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
          boxShadow: AppCardShadow.soft,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image fills the entire button, edge to edge.
              Image.asset(imagePath, fit: BoxFit.cover),
              // Dark gradient scrim at the bottom so the caption text
              // stays legible over whatever's in the photo underneath.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}