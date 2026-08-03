import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'home_screen.dart';
import 'activity_screen.dart';
import 'profile_screen.dart';
import '../utils/app_colors.dart';

/// Root navigation shell with an Expanding Chip bottom bar.
/// Each tab expands horizontally when active — premium fintech/web3 feel.
/// Bar has a transparent background so screen content shows through behind it.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 1; // Home stays center/default

  final List<Widget> _screens = const [
    ActivityScreen(),
    HomeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      body: _screens[_currentIndex],
      // Use extendBody so the screen content flows behind the bar
      extendBody: true,
      bottomNavigationBar: _ExpandingChipBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        theme: theme,
      ),
    );
  }
}

/// Expanding Chip bottom bar — each tab is a pill that expands sideways
/// when active, showing an icon + label. Inactive tabs show only the icon.
/// The bar itself is the ONLY visible element — the background is transparent.
class _ExpandingChipBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final ThemeProvider theme;

  const _ExpandingChipBar({
    required this.currentIndex,
    required this.onTap,
    required this.theme,
  });

  // Reduced from 72 to 58 for a smaller overall bar
  static const double barHeight = 58.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: barHeight + 16, // Reduced from +24 to +16
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduced padding
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.surface, // Only the pill has this color — rest is transparent
        borderRadius: BorderRadius.circular(32), // Slightly smaller radius to match smaller bar
        border: Border.all(
          color: AppColors.amber.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ExpandingChip(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long,
            label: 'Activity',
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
            theme: theme,
          ),
          _ExpandingChip(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
            theme: theme,
            isCenter: true,
          ),
          _ExpandingChip(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
            isActive: currentIndex == 2,
            onTap: () => onTap(2),
            theme: theme,
          ),
        ],
      ),
    );
  }
}

/// Individual expanding chip — animates width and shows label when active.
/// Reduced size for more compact appearance.
class _ExpandingChip extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final ThemeProvider theme;
  final bool isCenter;

  const _ExpandingChip({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.theme,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isActive 
        ? (isCenter ? AppColors.yellow : AppColors.amber) 
        : Colors.transparent;
    
    final iconColor = isActive 
        ? (isCenter ? AppColors.darkTextPrimary : AppColors.darkTextPrimary) 
        : theme.textPrimary;
    
    final labelColor = isActive 
        ? (isCenter ? AppColors.darkTextPrimary : AppColors.darkTextPrimary) 
        : theme.textPrimary;
    
    final inactiveBorderColor = theme.surfaceElevated.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 10, // Reduced from 20/12
          vertical: 8, // Reduced from 10
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24), // Reduced from 30
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: (isCenter ? AppColors.yellow : AppColors.amber)
                        .withValues(alpha: 0.4),
                    blurRadius: 16, // Reduced from 20
                    spreadRadius: 1, // Reduced from 2
                  ),
                ]
              : null,
          border: isActive
              ? null
              : Border.all(
                  color: inactiveBorderColor,
                  width: 1.5,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: iconColor,
              size: 20, // Reduced from 24
            ),
            if (isActive) ...[
              const SizedBox(width: 8), // Reduced from 10
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isActive ? 1.0 : 0.0,
                child: Text(
                  label,
                  style: TextStyle(
                    color: labelColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12, // Reduced from 14
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}