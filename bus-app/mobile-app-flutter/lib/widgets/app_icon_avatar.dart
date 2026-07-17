import 'package:flutter/material.dart';

// A circular colored backdrop behind an icon, giving list items an
// "illustrated" feel rather than a flat icon sitting directly on the
// card background — matches the avatar-style icons in the reference design.
class AppIconAvatar extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const AppIconAvatar({
    super.key,
    required this.icon,
    required this.color,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: size * 0.45),
    );
  }
}