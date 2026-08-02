// lib/screens/route_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import '../models/route_detail_model.dart';
// ignore: unused_import
import '../models/booking_model.dart';
import '../widgets/app_back_button.dart';
import '../widgets/full_screen_image_viewer.dart'; // Import the full-screen viewer
import 'booking_screen.dart';

/// Screen displaying detailed information about a tour route, including
/// hero image, description, and a scrollable list of tour stops with
/// image galleries. Supports deep-linking to a specific stop via targetStopId.
///
/// THEME: Converted to be theme-aware (light/dark). Uses ThemeProvider for
/// surface colors and text colors instead of hardcoded AppColors.black2/black3/white.
class RouteDetailScreen extends StatefulWidget {
  final RouteDetail route;
  final String? targetStopId;

  const RouteDetailScreen({super.key, required this.route, this.targetStopId});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  // Map to store GlobalKeys for each stop to enable scroll-to functionality
  final Map<String, GlobalKey> _stopKeys = {};

  @override
  void initState() {
    super.initState();
    
    // Assign a unique GlobalKey to each stop for position tracking
    for (var stop in widget.route.stops) {
      _stopKeys[stop.id] = GlobalKey();
    }

    // After the widget is built, scroll to the target stop if specified
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.targetStopId != null && _stopKeys.containsKey(widget.targetStopId)) {
        final targetContext = _stopKeys[widget.targetStopId]?.currentContext;
        if (targetContext != null) {
          // Smooth scroll animation to the target stop
          Scrollable.ensureVisible(
            targetContext, 
            duration: const Duration(milliseconds: 600), 
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access theme provider for light/dark mode aware colors
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.background, // now theme-aware
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(widget.route.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      // Wrap content in SingleChildScrollView for vertical scrolling
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image section - displays the main route banner image
            if (widget.route.imageUrl != null && widget.route.imageUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: widget.route.imageUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                // Loading placeholder while image loads
                placeholder: (context, url) => Container(
                  height: 220,
                  color: theme.surfaceElevated, // was AppColors.black3 — now theme-aware
                  child: const Center(child: CircularProgressIndicator(color: AppColors.yellow)),
                ),
                // Error fallback if image fails to load
                errorWidget: (context, url, error) => Container(
                  height: 220,
                  color: theme.surfaceElevated, // was AppColors.black3 — now theme-aware
                  child: const Icon(Icons.tour, size: 60, color: AppColors.yellow),
                ),
              ),
            
            // Route description section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route description text
                  Text(
                    widget.route.description, 
                    style: const TextStyle(
                      color: AppColors.grey, // grey stays as static accent
                      fontSize: 15, 
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Divider — uses theme-aware color instead of hardcoded white12
                  Divider(color: theme.textPrimary.withValues(alpha: 0.12)), // was Colors.white12 — now theme-aware
                  const SizedBox(height: 10),
                  // Section header for tour stops
                  Text(
                    'Tour Stops & Highlights', 
                    style: TextStyle(
                      color: theme.textPrimary, // was AppColors.white — now theme-aware
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // List of tour stops - using ListView.builder inside SingleChildScrollView
            // shrinkWrap: true makes it take only needed space
            // NeverScrollableScrollPhysics prevents nested scrolling issues
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.route.stops.length,
              itemBuilder: (context, index) {
                final stop = widget.route.stops[index];
                // Check if this stop is the target (for highlighting)
                final isTarget = widget.targetStopId == stop.id;

                return Container(
                  // Assign GlobalKey for scroll-to functionality
                  key: _stopKeys[stop.id],
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.surface, // was AppColors.black2 — now theme-aware
                    borderRadius: BorderRadius.circular(16),
                    // Highlight the target stop with a yellow border
                    border: Border.all(
                      color: isTarget ? AppColors.yellow : AppColors.amber.withValues(alpha: 0.2), 
                      width: isTarget ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stop header with number and name
                      Row(
                        children: [
                          // Numbered circle indicator
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.yellow, // yellow stays as brand accent
                            child: Text(
                              '${index + 1}', 
                              style: const TextStyle(
                                color: AppColors.black, // black on yellow — optimal contrast always
                                fontWeight: FontWeight.bold, 
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Stop name
                          Expanded(
                            child: Text(
                              stop.name, 
                              style: TextStyle(
                                color: theme.textPrimary, // was AppColors.white — now theme-aware
                                fontSize: 18, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Stop description
                      Text(
                        stop.description, 
                        style: const TextStyle(
                          color: AppColors.grey, // grey stays as static accent
                          fontSize: 14, 
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      
                      // Gallery section - only show if stop has images
                      if (stop.images.isNotEmpty) ...[
                        // Gallery label
                        const Text(
                          'Gallery', 
                          style: TextStyle(
                            color: AppColors.yellow, // yellow stays as brand accent
                            fontSize: 12, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Horizontal scrolling image gallery
                        SizedBox(
                          height: 160,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: stop.images.length,
                            itemBuilder: (context, imgIndex) {
                              return Container(
                                margin: const EdgeInsets.only(right: 10),
                                width: 220,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12), 
                                  color: theme.background, // was AppColors.black — now theme-aware (image placeholder background)
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  // Wrap image in GestureDetector for tap-to-view-fullscreen
                                  child: GestureDetector(
                                    onTap: () {
                                      // Navigate to full-screen image viewer
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => FullScreenImageViewer(
                                            images: stop.images,      // Pass all images for this stop
                                            initialIndex: imgIndex,   // Start from the tapped image
                                            stopName: stop.name,      // Show stop name in header
                                          ),
                                        ),
                                      );
                                    },
                                    child: CachedNetworkImage(
                                      imageUrl: stop.images[imgIndex],
                                      fit: BoxFit.cover,
                                      // Loading indicator while image loads
                                      placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.yellow, 
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      // Error fallback if image fails to load
                                      errorWidget: (context, url, error) => Container(
                                        color: theme.surfaceElevated, // was AppColors.black3 — now theme-aware
                                        child: const Icon(
                                          Icons.broken_image, 
                                          color: AppColors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            // Extra space at bottom to prevent bottom sheet overlap
            const SizedBox(height: 80),
          ],
        ),
      ),
      
      // Fixed bottom sheet with "Book This Tour" button
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        color: theme.surface, // was AppColors.black2 — now theme-aware
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // Navigate to booking screen with this route pre-selected
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (_) => BookingScreen(preselectedRouteId: widget.route.id),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.yellow, // yellow stays as brand accent
              foregroundColor: AppColors.black, // black text on yellow — optimal contrast always
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Book This Tour', 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}