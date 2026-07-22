import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// Splash sequence (total 5600ms, matching the requested ~5.6s):
//   0ms   - 2000ms: hero bus photo holds still, untouched (2 full seconds)
//   2000ms - 2600ms: circular iris closes over the photo, revealing
//                     the logo underneath (600ms transition)
//   2000ms - 2700ms: logo scales in with a slight pop as it's revealed
//   2600ms - 5600ms: logo holds alone on screen (3 full seconds)
//   throughout: a thin loading bar at the bottom fills linearly
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  static const String heroImagePath = 'assets/images/ksb_bus.jpeg';
  static const String logoImagePath = 'assets/images/logo.png';

  late final AnimationController _controller;
  late final Animation<double> _irisRadius;
  late final Animation<double> _logoScale;
  late final Animation<double> _ringOpacity;

  static const _totalMs = 5600;

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

    _irisRadius = Tween<double>(begin: 1.0, end: 0.0).animate(_interval(2000, 2600));
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(_interval(2000, 2700, curve: Curves.easeOutBack));
    _ringOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(_interval(2500, 2700, curve: Curves.easeOut));

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
              Center(
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Image.asset(logoImagePath, fit: BoxFit.contain),
                  ),
                ),
              ),
              if (_irisRadius.value > 0.001)
                ClipPath(
                  clipper: _IrisClipper(fraction: _irisRadius.value),
                  child: Image.asset(heroImagePath, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                ),
              if (_ringOpacity.value > 0.001)
                CustomPaint(
                  size: size,
                  painter: _IrisRingPainter(
                    fraction: _irisRadius.value,
                    opacity: _ringOpacity.value,
                    color: AppColors.yellow,
                  ),
                ),
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