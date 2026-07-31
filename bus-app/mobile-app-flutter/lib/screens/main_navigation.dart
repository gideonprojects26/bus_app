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
  int _currentIndex = 1; // Home stays center/default

  final List<Widget> _screens = const [
    ActivityScreen(),
    HomeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _ScallopBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// A bottom bar whose top edge smoothly curves inward around the
// center button, "cradling" it in a wave-shaped dip, rather than the
// button just floating above a flat bar edge.
class _ScallopBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ScallopBottomBar({required this.currentIndex, required this.onTap});

  static const double barHeight = 68.0;
  static const double notchRadius = 38.0;
  static const double buttonSize = 64.0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final notchCenterX = screenWidth / 2;

    return SizedBox(
      height: barHeight + 24,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // The curved bar shape itself, drawn with a smooth dip cut
          // into its top edge around the center button's position.
          CustomPaint(
            size: Size(screenWidth, barHeight),
            painter: _ScallopPainter(
              notchCenterX: notchCenterX,
              notchRadius: notchRadius,
              fillColor: AppColors.black2,
              borderColor: AppColors.amber.withValues(alpha: 0.25),
            ),
            child: SizedBox(
              height: barHeight,
              width: screenWidth,
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
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
                    const SizedBox(width: notchRadius * 2),
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
            ),
          ),

          // The raised circular Home button, sitting inside the dip.
          Positioned(
            bottom: barHeight - (buttonSize / 2) - 10,
            child: GestureDetector(
              onTap: () => onTap(1),
              child: Container(
                width: buttonSize,
                height: buttonSize,
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
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Draws the bar's fill with a smooth wave-shaped dip cut into the top
// edge, centered on notchCenterX, using cubic Bezier curves for a
// soft, rounded transition rather than a sharp cutout.
class _ScallopPainter extends CustomPainter {
  final double notchCenterX;
  final double notchRadius;
  final Color fillColor;
  final Color borderColor;

  _ScallopPainter({
    required this.notchCenterX,
    required this.notchRadius,
    required this.fillColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final dipWidth = notchRadius * 2.6;
    final dipDepth = notchRadius * 0.95;

    final leftCurveStart = notchCenterX - dipWidth;
    final rightCurveEnd = notchCenterX + dipWidth;

    path.moveTo(0, 0);
    path.lineTo(leftCurveStart, 0);

    // Curve down into the dip
    path.cubicTo(
      leftCurveStart + dipWidth * 0.35, 0,
      notchCenterX - notchRadius * 1.15, dipDepth,
      notchCenterX, dipDepth,
    );
    // Curve back up out of the dip
    path.cubicTo(
      notchCenterX + notchRadius * 1.15, dipDepth,
      rightCurveEnd - dipWidth * 0.35, 0,
      rightCurveEnd, 0,
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final fillPaint = Paint()..color = fillColor;
    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final borderPath = Path();
    borderPath.moveTo(0, 0);
    borderPath.lineTo(leftCurveStart, 0);
    borderPath.cubicTo(
      leftCurveStart + dipWidth * 0.35, 0,
      notchCenterX - notchRadius * 1.15, dipDepth,
      notchCenterX, dipDepth,
    );
    borderPath.cubicTo(
      notchCenterX + notchRadius * 1.15, dipDepth,
      rightCurveEnd - dipWidth * 0.35, 0,
      rightCurveEnd, 0,
    );
    borderPath.lineTo(size.width, 0);
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _ScallopPainter oldDelegate) =>
      oldDelegate.notchCenterX != notchCenterX || oldDelegate.notchRadius != notchRadius;
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