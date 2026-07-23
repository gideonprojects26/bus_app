import 'package:flutter/material.dart';

/*class AppColors {
  static const Color black = Color(0xFF191919);  // was 0xFF0D0D0D — softer charcoal, less harsh than pure near-black
  static const Color black2 = Color(0xFF242424);  // card surface
  static const Color black3 = Color(0xFF2E2E2E);  // elevated surface (modals, lifted panels)
  static const Color yellow = Color(0xFFFFC107);   // primary actions + prices ONLY
  static const Color amber = Color(0xFFC9A227);    // secondary accent: borders, inactive highlights
  static const Color red = Color(0xFFE53935);       // urgent/destructive only
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9E9E9E);
}
*/

// Static palette values only — these are just the raw color swatches,
// not tied to "background" or "text" roles. AppColors stays available
// for any code that intentionally wants a fixed brand color regardless
// of theme (e.g. the yellow accent never changes between light/dark).
class AppColors {
  static const Color yellow = Color(0xFFFFC107);
  static const Color amber = Color(0xFFC9A227);
  static const Color red = Color(0xFFE53935);
  static const Color grey = Color(0xFF9E9E9E);

  // Dark theme surface/text values
  static const Color darkBackground = Color(0xFF191919);
  static const Color darkSurface = Color(0xFF242424);
  static const Color darkSurfaceElevated = Color(0xFF2E2E2E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);

  // Light theme surface/text values
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF3F3F3);
  static const Color lightSurfaceElevated = Color(0xFFE8E8E8);
  static const Color lightTextPrimary = Color(0xFF191919);

  // LEGACY ALIASES — kept so the ~20 screens built before the light/dark
  // refactor keep compiling without edits. These always resolve to the
  // dark theme values, regardless of the user's actual theme choice.
  // As each screen gets converted to use ThemeProvider (theme.background,
  // theme.textPrimary, etc. via context.watch<ThemeProvider>()), its
  // references to these aliases get replaced and it becomes properly
  // theme-aware. Until a screen is converted, it will simply stay
  // dark-themed even if the user switches to light mode — that's the
  // known, intentional tradeoff during this transition period.
  static const Color black = darkBackground;
  static const Color black2 = darkSurface;
  static const Color black3 = darkSurfaceElevated;
  static const Color white = darkTextPrimary;
}