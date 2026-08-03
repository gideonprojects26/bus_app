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
class _ExpandingChipBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final ThemeProvider theme;

  const _ExpandingChipBar({
    required this.currentIndex,
    required this.onTap,
    required this.theme,
  });

  static const double barHeight = 72.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: barHeight + 24,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.surface, // Maps to darkSurface or lightSurface
        borderRadius: BorderRadius.circular(40),
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
    // Colors based on active state
    // Brand accent colors (yellow/amber) don't change with theme
    final bgColor = isActive 
        ? (isCenter ? AppColors.yellow : AppColors.amber) 
        : Colors.transparent;
    
    // Active icon/text colors contrast with the brand accent backgrounds
    final iconColor = isActive 
        ? (isCenter ? AppColors.darkTextPrimary : AppColors.darkTextPrimary) 
        : theme.textPrimary; // Inactive tabs use theme-aware text color
    
    final labelColor = isActive 
        ? (isCenter ? AppColors.darkTextPrimary : AppColors.darkTextPrimary) 
        : theme.textPrimary; // Inactive tabs use theme-aware text color
    
    // Inactive border uses theme-aware surface color for subtle contrast
    final inactiveBorderColor = theme.surfaceElevated.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: () {
        // Haptic feedback for premium feel
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 20 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: (isCenter ? AppColors.yellow : AppColors.amber)
                        .withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
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
              size: 24,
            ),
            if (isActive) ...[
              const SizedBox(width: 10),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isActive ? 1.0 : 0.0,
                child: Text(
                  label,
                  style: TextStyle(
                    color: labelColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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