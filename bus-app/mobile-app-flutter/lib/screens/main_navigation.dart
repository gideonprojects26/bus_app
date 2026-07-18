import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'activity_screen.dart';
import 'profile_screen.dart';
import '../utils/app_colors.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // Index order matches the visual left-to-right layout: Activity (0),
  // Home (1, center), Profile (2) — Home sits in the middle as requested.
  int _currentIndex = 1;

  final List<Widget> _screens = const [
    ActivityScreen(),
    HomeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _CustomBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// Custom bottom bar: flat side tabs (Activity, Profile) plus a large
// circular Home button that overlaps the top edge of the bar, giving
// it a "raised" appearance distinct from the other two tabs.
class _CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _CustomBottomBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const barHeight = 64.0;
    const centerButtonSize = 66.0;

    return SizedBox(
      height: barHeight + 26, // extra height so the raised button has room to overlap upward
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // The flat bar itself, with a notch-like gap left empty in the
          // middle for the raised button to sit over.
          Container(
            height: barHeight,
            decoration: BoxDecoration(
              color: AppColors.black2,
              border: Border(top: BorderSide(color: AppColors.amber.withValues(alpha: 0.2))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SideTabItem(
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long,
                    label: 'Activity',
                    isActive: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                ),
                const SizedBox(width: centerButtonSize), // reserved empty space for the raised button
                Expanded(
                  child: _SideTabItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Profile',
                    isActive: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                ),
              ],
            ),
          ),

          // The raised, larger circular Home button, positioned to
          // overlap upward past the bar's top edge.
          Positioned(
            bottom: barHeight - (centerButtonSize / 2) - 6,
            child: GestureDetector(
              onTap: () => onTap(1),
              child: Container(
                width: centerButtonSize,
                height: centerButtonSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentIndex == 1 ? AppColors.yellow : AppColors.black3,
                  border: Border.all(
                    color: currentIndex == 1 ? AppColors.yellow : AppColors.amber.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (currentIndex == 1 ? AppColors.yellow : Colors.black).withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  currentIndex == 1 ? Icons.home : Icons.home_outlined,
                  color: currentIndex == 1 ? AppColors.black : AppColors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideTabItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SideTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.yellow : AppColors.grey;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isActive ? activeIcon : icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}