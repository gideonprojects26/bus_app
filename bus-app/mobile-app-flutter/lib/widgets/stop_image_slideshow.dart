import 'dart:async';
import 'package:flutter/material.dart';
import '../models/tour_route_model.dart';
import '../utils/app_colors.dart';

// Auto-playing slideshow of stop photos and captions for a given route,
// sourced directly from the route model's database records (`images` array).
class StopImageSlideshow extends StatefulWidget {
  final List<RouteImage> images;

  const StopImageSlideshow({super.key, required this.images});

  @override
  State<StopImageSlideshow> createState() => _StopImageSlideshowState();
}

class _StopImageSlideshowState extends State<StopImageSlideshow> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    if (widget.images.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!mounted) return;
        final next = (_currentPage + 1) % widget.images.length;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        );
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
    if (widget.images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 180, // Height adjusted to comfortably accommodate image and caption
      child: PageView.builder(
        controller: _controller,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          final imageItem = widget.images[index];

          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              color: AppColors.black3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Asset Image
                  Image.asset(
                    imageItem.path,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.image_outlined, color: AppColors.grey, size: 28),
                      );
                    },
                  ),

                  // 2. Caption Overlay Bar with Gradient
                  if (imageItem.caption.isNotEmpty)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        child: Text(
                          imageItem.caption,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                  // 3. Page Counter Badge (e.g., 1/6)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${index + 1}/${widget.images.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}