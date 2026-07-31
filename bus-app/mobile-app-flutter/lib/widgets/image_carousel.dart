// lib/widgets/image_carousel.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({super.key});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  // Controller for the PageView to handle swipe and programmatic navigation
  final PageController _controller = PageController();
  
  // Tracks which image is currently displayed
  int _currentPage = 0;
  
  // Timer for automatic slideshow advancement
  Timer? _autoPlayTimer;

  // Local asset image paths - these are bundled with the app
  // Make sure these exact files exist in your assets/images/ folder
  // and are declared in pubspec.yaml under flutter > assets
  final List<String> _imagePaths = [
    'assets/images/bus1.jpg',
    'assets/images/bus_1.jpg',
    'assets/images/bus_2.jpg',
    'assets/images/bus_3.jpg',
    'assets/images/bus_4.jpg',
    'assets/images/bus_5.jpg',
    'assets/images/bus_6.jpg',
  ];

  @override
  void initState() {
    super.initState();
    
    // Preload images in the background without blocking the UI
    // This eliminates lag when switching between images
    _preloadImagesInBackground();
    
    // Start auto-play immediately - images will show even while preloading
    _startAutoPlay();
  }

  // Preload all asset images into memory cache in the background
  // This doesn't block the UI - carousel shows immediately
  Future<void> _preloadImagesInBackground() async {
    // Load each image into Flutter's image cache
    for (final path in _imagePaths) {
      // precacheImage loads the image into memory without blocking the UI
      // AssetImage handles the asset bundle resolution
      await precacheImage(
        AssetImage(path),
        context,
      );
    }
  }

  // Start automatic slideshow with a 4-second interval
  void _startAutoPlay() {
    // Cancel any existing timer to prevent multiple timers running
    _autoPlayTimer?.cancel();
    
    // Create periodic timer that advances to the next image
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      // Check if widget is still mounted to prevent memory leaks
      if (!mounted) return;
      
      // Calculate next page index, looping back to 0 after the last image
      final nextPage = (_currentPage + 1) % _imagePaths.length;
      
      // Animate to the next page with smooth easing
      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  // Reset auto-play timer (useful when user manually swipes)
  void _resetAutoPlay() {
    _autoPlayTimer?.cancel();
    _startAutoPlay();
  }

  @override
  void dispose() {
    // Clean up timer and controller to prevent memory leaks
    _autoPlayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Display carousel immediately - images show right away
    // Background preloading ensures smooth transitions
    return Column(
      children: [
        // Image carousel container
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _controller,
            // Update current page index when user swipes manually
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              // Reset auto-play timer on manual swipe to give user time to view
              _resetAutoPlay();
            },
            itemCount: _imagePaths.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    // Display asset image - first load might be slightly slow
                    // but subsequent transitions will be smooth thanks to preloading
                    image: DecorationImage(
                      image: AssetImage(_imagePaths[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 10),
        
        // Dot indicators showing current position in carousel
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_imagePaths.length, (index) {
            // Animated dot that smoothly transitions between active/inactive states
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              // Active dot is wider to indicate current position
              width: _currentPage == index ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                // Yellow for active dot, grey for inactive dots
                color: _currentPage == index ? AppColors.yellow : AppColors.grey,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}