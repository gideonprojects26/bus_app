// lib/widgets/stop_image_slideshow.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/route_detail_model.dart';
import '../screens/route_detail_screen.dart';
import '../utils/app_colors.dart';

class StopImageSlideshow extends StatefulWidget {
  final RouteDetail route; // Accepts full RouteDetail object

  const StopImageSlideshow({
    super.key,
    required this.route,
  });

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
    // Start auto-play only if there is more than 1 stop to slide through
    if (widget.route.stops.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!mounted) return;
        final next = (_currentPage + 1) % widget.route.stops.length;
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
    if (widget.route.stops.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _controller,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemCount: widget.route.stops.length,
        itemBuilder: (context, index) {
          final stopItem = widget.route.stops[index];
          final String? displayImage = stopItem.primaryImage; // Uses new primaryImage getter

          return GestureDetector(
            onTap: () {
              // Navigates to details screen and scrolls to the exact stop ID
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RouteDetailScreen(
                    route: widget.route,
                    targetStopId: stopItem.id,
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                color: AppColors.black3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Network Image from Cloudinary
                    if (displayImage != null && displayImage.isNotEmpty)
                      Image.network(
                        displayImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: AppColors.grey,
                              size: 28,
                            ),
                          );
                        },
                      )
                    else
                      const Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: AppColors.grey,
                          size: 28,
                        ),
                      ),

                    // Caption Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.8),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        child: Text(
                          stopItem.name,
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

                    // Counter Badge (e.g. 1/6)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${index + 1}/${widget.route.stops.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}