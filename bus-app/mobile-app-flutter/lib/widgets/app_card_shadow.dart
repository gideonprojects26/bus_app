import 'package:flutter/material.dart';

// A reusable decoration for card-style containers throughout the app,
// giving them a soft drop shadow for visual depth instead of sitting
// flat against the black background.
class AppCardShadow {
  static List<BoxShadow> get soft => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}