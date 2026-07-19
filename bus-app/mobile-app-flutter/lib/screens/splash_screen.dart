import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// Splash sequence (total 2 seconds):
//   0.0s - 0.5s: hero bus photo shown, untouched
//   0.5s - 1.4s: a circular "iris" (like a camera aperture closing)
//                shrinks over the photo, gradually revealing the logo
//                underneath — this is the "morph" from photo to logo
//   0.65s - 1.5s: logo pops in with a subtle scale-up as it's revealed
//   throughout: a thin loading bar at the bottom fills linearly
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  // Update these to match your exact filenames if they differ.
  static const String heroImagePath = 'assets/images/ksb_bus.jpeg';
  static const String logoImagePath = 'assets/images/logo.png';

  late final AnimationController _controller;
  late final Animation<double> _irisRadius; // 1.0 = fully covering photo, 0.0 = fully revealed logo
  late final Animation<double> _logoScale;
  late final Animation<double> _ringOpacity;

  static const _totalMs = 2000;

  Animation<double> _interval(double startMs, double endMs, {Curve curve = Curves.easeInOutCubic}) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(startMs / _totalMs, endMs / _totalMs, curve: curve),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: _totalMs));

    _irisRadius = Tween<double>(begin: 1.0, end: 0.0).animate(_interval(500, 1400));
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(_interval(650, 1500, curve: Curves.easeOutBack));
    _ringOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(_interval(1300, 1500, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Base layer: the logo, always present, gently scaling
              // in as it's revealed by the shrinking iris above it.
              Center(
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Image.asset(logoImagePath, fit: BoxFit.contain),
                  ),
                ),
              ),

              // Top layer: the bus photo, clipped by a shrinking
              // circular mask — as the radius shrinks toward 0, less
              // of the photo remains, revealing the logo beneath it.
              if (_irisRadius.value > 0.001)
                ClipPath(
                  clipper: _IrisClipper(fraction: _irisRadius.value),
                  child: Image.asset(heroImagePath, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                ),

              // Thin accent ring tracing the iris edge as it closes,
              // fading out once the reveal completes.
              if (_ringOpacity.value > 0.001)
                CustomPaint(
                  size: size,
                  painter: _IrisRingPainter(
                    fraction: _irisRadius.value,
                    opacity: _ringOpacity.value,
                    color: AppColors.yellow,
                  ),
                ),

              // Loading bar at the bottom, filling linearly across the
              // entire splash duration.
              Positioned(
                left: 40,
                right: 40,
                bottom: 48,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 4,
                    color: AppColors.black3,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _controller.value.clamp(0.0, 1.0),
                        child: Container(color: AppColors.yellow),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Clips its child to a circle centered on the widget, with a radius
// scaling from fully covering the screen (fraction 1.0) down to a
// single point (fraction 0.0) — the mechanism behind the iris reveal.
class _IrisClipper extends CustomClipper<Path> {
  final double fraction;

  _IrisClipper({required this.fraction});

  @override
  Path getClip(Size size) {
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height) / 2;
    final radius = maxRadius * fraction;
    final center = Offset(size.width / 2, size.height / 2);
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(covariant _IrisClipper oldClipper) => oldClipper.fraction != fraction;
}

// Draws a thin fading ring at the current iris radius, as a decorative
// touch tracing the edge of the closing circle.
class _IrisRingPainter extends CustomPainter {
  final double fraction;
  final double opacity;
  final Color color;

  _IrisRingPainter({required this.fraction, required this.opacity, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height) / 2;
    final radius = maxRadius * fraction;
    final center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()
      ..color = color.withValues(alpha: opacity * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _IrisRingPainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.opacity != opacity;
}