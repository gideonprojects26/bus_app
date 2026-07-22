import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// Auto-playing slideshow of stop photos for a given route, sourced
// from assets/images/stops/<route-slug>/<stop-number>.jpg. If a
// specific stop's photo hasn't been added yet, shows a placeholder
// icon instead of crashing, so photos can be added incrementally.
class StopImageSlideshow extends StatefulWidget {
  final String routeName;
  final int stopCount;

  const StopImageSlideshow({super.key, required this.routeName, required this.stopCount});

  @override
  State<StopImageSlideshow> createState() => _StopImageSlideshowState();
}

class _StopImageSlideshowState extends State<StopImageSlideshow> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _currentPage = 0;

  String get _routeSlug => widget.routeName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');

  @override
  void initState() {
    super.initState();
    if (widget.stopCount > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!mounted) return;
        final next = (_currentPage + 1) % widget.stopCount;
        _controller.animateToPage(next, duration: const Duration(milliseconds: 450), curve: Curves.easeInOut);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stopCount == 0) return const SizedBox.shrink();

    return SizedBox(
      height: 130,
      child: PageView.builder(
        controller: _controller,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemCount: widget.stopCount,
        itemBuilder: (context, index) {
          final imagePath = 'assets/images/stops/$_routeSlug/${index + 1}.jpg';
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              color: AppColors.black3,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.image_outlined, color: AppColors.grey, size: 28),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}