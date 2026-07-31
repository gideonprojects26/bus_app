// lib/widgets/full_screen_image_viewer.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_colors.dart';

class FullScreenImageViewer extends StatefulWidget {
  // The list of image URLs for the specific stop
  final List<String> images;
  
  // The index of the image that was tapped (so we start from there)
  final int initialIndex;
  
  // The name of the stop (for the header)
  final String stopName;

  const FullScreenImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.stopName,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  // Controller for the PageView to handle swipe navigation
  late PageController _pageController;
  
  // Track the current page index for the header and arrows
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    // Start from the image that was tapped
    _currentPage = widget.initialIndex;
    
    // Initialize PageController with the starting index
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    // Clean up the controller to prevent memory leaks
    _pageController.dispose();
    super.dispose();
  }

  // Navigate to the previous image
  void _goToPrevious() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Navigate to the next image
  void _goToNext() {
    if (_currentPage < widget.images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Black background for immersive full-screen viewing
      backgroundColor: Colors.black,
      
      // SafeArea ensures content doesn't overlap with device notches/status bars
      body: SafeArea(
        child: Stack(
          children: [
            // Main image gallery using PageView for swipe navigation
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              // Update _currentPage when user swipes
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                // Each page shows one image with interactive features
                return InteractiveViewer(
                  // Allows pinch-to-zoom functionality
                  minScale: 1.0,
                  maxScale: 5.0,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: widget.images[index],
                      // Show loading indicator while image loads
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.yellow,
                        ),
                      ),
                      // Show error icon if image fails to load
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: AppColors.grey,
                          size: 60,
                        ),
                      ),
                      // Fit the image within the screen while maintaining aspect ratio
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),

            // Previous button (left arrow) - only show if not on first image
            if (_currentPage > 0)
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _goToPrevious,
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Next button (right arrow) - only show if not on last image
            if (_currentPage < widget.images.length - 1)
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _goToNext,
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Header section with stop name, image counter, and close button
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                // Semi-transparent gradient background for better text visibility
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Back/Close button
                    Material(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Stop name and image counter
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Stop name
                          Text(
                            widget.stopName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Image counter (e.g., "3 / 7")
                          Text(
                            '${_currentPage + 1} / ${widget.images.length}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom dots indicator for visual navigation feedback
            if (widget.images.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.images.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 10 : 8,
                      height: _currentPage == index ? 10 : 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? AppColors.yellow
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}