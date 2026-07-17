// splash_screen.dart
//
// Bus Tours animated splash screen.
// Sequence:
//   1. Ken Burns zoom-out on the hero bus photo
//   2. Dark gradient scrim fades in (keeps text legible over the photo)
//   3. Eyebrow location tag rises in ("KAMPALA · UGANDA")
//   4. "BUS TOURS" wordmark rises + fades in
//   5. Tagline rises + fades in
//   6. Signature "route line" draws itself across the bottom, stops
//      pop in one by one, and a small bus marker travels the line
//   7. "Loading route…" pulses
//
// SETUP CHECKLIST:
// 1. Confirm your photo file sits at assets/images/ (already declared
//    as a folder in pubspec.yaml's flutter -> assets section, so no
//    new pubspec entry is needed as long as the folder is listed).
// 2. Update heroImagePath below to match your exact filename.
// 3. This widget takes no required parameters — main.dart's AuthGate
//    swaps it out automatically once the session check finishes, so
//    no onFinished callback is needed here.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  // IMPORTANT: update this to match the exact filename you placed in
  // assets/images/. Case-sensitive, including the file extension.
  static const String heroImagePath = 'assets/images/ksb_bus.jpeg';

  late final AnimationController _controller;

  // Each sub-animation is mapped to its own time window (in ms) within
  // the single 4600ms master timeline below, so everything plays in a
  // coordinated sequence rather than all at once.
  late final Animation<double> _photoScale;
  late final Animation<double> _scrimOpacity;
  late final Animation<double> _eyebrow;
  late final Animation<double> _wordmark;
  late final Animation<double> _tagline;
  late final Animation<double> _routeDraw;
  late final Animation<double> _loading;

  static const _totalMs = 4600;

  // Converts a start/end millisecond window into a CurvedAnimation
  // scoped to that portion of the master timeline (0.0 to 1.0).
  Animation<double> _interval(double startMs, double endMs, {Curve curve = Curves.easeOutCubic}) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(startMs / _totalMs, endMs / _totalMs, curve: curve),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: _totalMs));

    // Photo zooms out slowly across the ENTIRE timeline (0 to 4600ms),
    // giving a continuous subtle motion behind everything else.
    _photoScale = Tween<double>(begin: 1.22, end: 1.04).animate(_interval(0, 4600));

    _scrimOpacity = _interval(100, 1200, curve: Curves.easeOut);
    _eyebrow = _interval(1850, 2550);
    _wordmark = _interval(1050, 1900);
    _tagline = _interval(1650, 2350);
    _routeDraw = _interval(2200, 4100, curve: Curves.easeInOutCubic);
    _loading = _interval(4300, 4600);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand, // photo fills the entire screen, any device size
            children: [
              // 1. Ken Burns zoom on the hero photo
              Transform.scale(
                scale: _photoScale.value,
                alignment: const Alignment(0.16, -0.16),
                child: Image.asset(heroImagePath, fit: BoxFit.cover),
              ),

              // 2. Dark scrim gradient so text stays legible over the photo
              Opacity(
                opacity: _scrimOpacity.value,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.28, 0.55, 1.0],
                      colors: [
                        Color(0x8C191919),
                        Color(0x0D191919),
                        Color(0x26191919),
                        Color(0xEB191919),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Eyebrow location tag — top left, small red dot + label.
              // Position uses a PERCENTAGE of screen height (0.06), so it
              // sits proportionally in the same spot on any device size.
              Positioned(
                top: screenHeight * 0.06,
                left: 32,
                child: _rise(
                  _eyebrow,
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'KAMPALA \u00b7 UGANDA',
                        style: GoogleFonts.robotoMono(color: AppColors.amber, fontSize: 12, letterSpacing: 3),
                      ),
                    ],
                  ),
                ),
              ),

              // 4 & 5. Wordmark + tagline, positioned near the bottom third.
              Positioned(
                left: 32,
                right: 32,
                bottom: screenHeight * 0.18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _rise(
                      _wordmark,
                      // FittedBox shrinks the text automatically if the
                      // available width is too narrow to fit at full
                      // size (e.g. smaller/budget Android phones),
                      // instead of overflowing or wrapping awkwardly.
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'BUS TOURS',
                          style: GoogleFonts.poppins(
                            fontSize: 48,
                            height: 0.95,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _rise(
                      _tagline,
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'RELIGIOUS TOUR \u00b7 CITY HIGHLIGHTS TOUR',
                          style: GoogleFonts.inter(
                            color: AppColors.white.withValues(alpha: 0.88),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 6. Signature route line — draws left to right, stops pop
              // in as the line reaches them, bus marker travels along it.
              // Width automatically matches the screen (left:32, right:32),
              // so the CustomPainter's canvas size is already responsive.
              Positioned(
                left: 32,
                right: 32,
                bottom: screenHeight * 0.08,
                height: 30,
                child: CustomPaint(
                  painter: _RoutePainter(
                    progress: _routeDraw.value,
                    accent: AppColors.yellow,
                    track: AppColors.white,
                    marker: AppColors.red,
                  ),
                ),
              ),

              // 7. Loading label — bottom right, pulses continuously
              // once it fades in near the end of the timeline.
              Positioned(
                right: 32,
                bottom: screenHeight * 0.08 - 22,
                child: _rise(
                  _loading,
                  _PulsingText(
                    text: 'LOADING ROUTE\u2026',
                    style: GoogleFonts.robotoMono(color: AppColors.white.withValues(alpha: 0.55), fontSize: 11, letterSpacing: 2),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Shared "rise + fade in" effect: content starts 20px lower and fully
  // transparent, then rises to its natural position while fading in,
  // driven by whichever Animation<double> is passed in.
  Widget _rise(Animation<double> a, Widget child) {
    return Opacity(
      opacity: a.value.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, (1 - a.value.clamp(0.0, 1.0)) * 20),
        child: child,
      ),
    );
  }
}

// Draws the dashed background track, the animated yellow progress
// line, four stop markers that pop in sequence as the line reaches
// them, and a red bus marker that travels along the completed
// portion of the line. All positions are relative to `size`, which
// Flutter automatically sets to match the CustomPaint widget's actual
// on-screen dimensions — so this scales correctly with screen width.
class _RoutePainter extends CustomPainter {
  final double progress; // 0..1, how far along the line has drawn
  final Color accent, track, marker;

  _RoutePainter({required this.progress, required this.accent, required this.track, required this.marker});

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;

    // Background dashed track (always fully visible, faint)
    final trackPaint = Paint()
      ..color = track.withValues(alpha: 0.28)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    _drawDashed(canvas, Offset(0, midY), Offset(size.width, midY), trackPaint);

    // Solid progress line, grows from left to right as `progress` increases
    final progressPaint = Paint()
      ..color = accent
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, midY), Offset(size.width * progress, midY), progressPaint);

    // Four stop markers at 0%, 33%, 66%, 100% along the line. Each pops
    // in with a small bounce once the progress line has drawn slightly
    // past its position (the "* 0.92" threshold creates that slight lag).
    final stopXs = [0.0, 0.33, 0.66, 1.0];
    for (var i = 0; i < stopXs.length; i++) {
      final threshold = stopXs[i] * 0.92;
      if (progress >= threshold) {
        final t = ((progress - threshold) / 0.08).clamp(0.0, 1.0);
        final r = (i == 3 ? 6.5 : 5.0) * Curves.easeOutBack.transform(t);
        final paint = Paint()..color = i == 3 ? accent : track;
        canvas.drawCircle(Offset(stopXs[i] * size.width, midY), r, paint);
        // The final stop gets an extra dark ring outline to stand out
        // as the "destination" marker.
        if (i == 3) {
          canvas.drawCircle(
            Offset(stopXs[i] * size.width, midY),
            r,
            Paint()
              ..color = AppColors.black
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
      }
    }

    // Traveling bus marker sits exactly at the current progress point.
    if (progress > 0.01) {
      canvas.drawCircle(Offset(size.width * progress, midY), 9, Paint()..color = marker);
      canvas.drawCircle(
        Offset(size.width * progress, midY),
        9,
        Paint()
          ..color = track
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  // Draws a dashed line between two points using fixed dash/gap
  // lengths, used for the background track.
  void _drawDashed(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 6.0, gap = 8.0;
    final total = (b - a).distance;
    final dir = (b - a) / total;
    double drawn = 0;
    while (drawn < total) {
      final segEnd = (drawn + dash).clamp(0, total).toDouble();
      canvas.drawLine(a + dir * drawn, a + dir * segEnd, paint);
      drawn += dash + gap;
    }
  }

  // Only repaint when progress actually changes, avoiding wasted redraws.
  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) => oldDelegate.progress != progress;
}

// Small helper widget that continuously pulses its opacity back and
// forth, used for the "LOADING ROUTE…" label so it feels "alive"
// rather than static once it appears.
class _PulsingText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _PulsingText({required this.text, required this.style});

  @override
  State<_PulsingText> createState() => _PulsingTextState();
}

class _PulsingTextState extends State<_PulsingText> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.55, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Text(widget.text, style: widget.style),
    );
  }
}