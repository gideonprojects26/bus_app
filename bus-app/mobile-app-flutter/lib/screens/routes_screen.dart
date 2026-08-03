// lib/screens/routes_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import '../models/route_detail_model.dart';
import '../services/cache_service.dart';
import '../widgets/stop_image_slideshow.dart';
import '../widgets/app_back_button.dart';
import 'route_detail_screen.dart';

/// Screen displaying all available tour routes with expandable stop lists.
/// Each route shows a name, description, auto-playing image slideshow,
/// and an expandable section listing all tour stops.
///
/// DATA: Uses offline-first CacheService — loads from local SQLite
/// instantly, then syncs with the backend in the background. Works
/// fully offline once data has been cached.
///
/// THEME: Converted to be theme-aware (light/dark). Uses ThemeProvider for
/// surface colors and text colors instead of hardcoded AppColors.black2/white.
class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  // List to store all available tour routes (from cache or backend)
  List<RouteDetail> _routes = [];
  
  // Loading state to show spinner while reading from cache on first launch
  bool _isLoading = true;
  
  // Error message to display if something goes wrong
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Fetch routes using offline-first cache
    _fetchRoutes();
  }

  /// Loads routes using the offline-first cache.
  /// Reads from local SQLite instantly (works without internet),
  /// then syncs with the backend in the background. If backend
  /// data has changed, the UI refreshes automatically via the
  /// onDataChanged callback.
  Future<void> _fetchRoutes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final routes = await CacheService.getRoutes(
        onDataChanged: (freshRoutes) {
          // Backend had new data — refresh the list so the user
          // sees the latest routes without manual refresh
          if (mounted) {
            setState(() {
              _routes = freshRoutes;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _routes = routes;
          _isLoading = false;
        });
      }
    } catch (e) {
      // If cache is completely empty (first launch with no internet),
      // show a helpful error message with a retry option
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load routes. Check your connection.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access theme provider for light/dark mode aware colors
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.background, // now theme-aware
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Available Routes'),
      ),
      body: _isLoading
          // Show loading spinner while reading from cache or fetching
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.yellow), // yellow stays as brand accent
            )
          : _routes.isEmpty
              // Show error state with retry button if no routes available
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Display error message or default empty message
                        Text(
                          _errorMessage ?? 'No routes available.', 
                          style: const TextStyle(color: AppColors.grey), // grey stays as static accent
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Retry button — calls CacheService again which will
                        // attempt to fetch from backend if internet is available
                        ElevatedButton(
                          onPressed: _fetchRoutes, 
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              // Display list of available routes (from cache or fresh backend data)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _routes.length,
                  itemBuilder: (context, index) {
                    // Get current route details from the list
                    final routeDetail = _routes[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: theme.surface, // was AppColors.black2 — now theme-aware
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.amber.withValues(alpha: 0.3), // amber stays as static accent border
                        ),
                      ),
                      // Override theme to remove divider lines in ExpansionTile
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Route card header section
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Route name row (price tag removed)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Route name - takes full width now
                                      Expanded(
                                        child: Text(
                                          routeDetail.name, 
                                          style: TextStyle(
                                            color: theme.textPrimary, // was AppColors.white — now theme-aware
                                            fontSize: 20, 
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      // Price tag was previously here - now removed
                                      // to keep the UI clean and minimal
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Route description (limited to 2 lines)
                                  Text(
                                    routeDetail.description, 
                                    maxLines: 2, 
                                    overflow: TextOverflow.ellipsis, 
                                    style: const TextStyle(
                                      color: AppColors.grey, // grey stays as static accent
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Auto-playing image slideshow of route stops.
                                  // Images load from CachedNetworkImage cache — works offline.
                                  if (routeDetail.stops.isNotEmpty) 
                                    StopImageSlideshow(route: routeDetail),
                                ],
                              ),
                            ),
                            
                            // Expandable section showing all stops on this route.
                            // Expands in place instead of navigating to a separate screen.
                            // Tapping an individual stop opens the full detail screen,
                            // automatically scrolled to that specific stop.
                            // All stop data (names, descriptions) comes from the cache.
                            ExpansionTile(
                              title: const Text(
                                'View Stops on this Route', 
                                style: TextStyle(
                                  color: AppColors.yellow, // yellow stays as brand accent
                                  fontSize: 13, 
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              iconColor: AppColors.yellow, // yellow stays as brand accent
                              collapsedIconColor: AppColors.yellow, // yellow stays as brand accent
                              children: routeDetail.stops.asMap().entries.map((entry) {
                                // entry.key = index, entry.value = TourStop object
                                final stop = entry.value;
                                
                                return ListTile(
                                  onTap: () {
                                    // Navigate to route detail screen, scrolled to this specific stop.
                                    // Passes the full route object (with cached stops, images, descriptions)
                                    // so the detail screen works fully offline.
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RouteDetailScreen(
                                          route: routeDetail, 
                                          targetStopId: stop.id,
                                        ),
                                      ),
                                    );
                                  },
                                  // Numbered circle indicator for each stop
                                  leading: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppColors.yellow, // yellow stays as brand accent
                                    child: Text(
                                      '${entry.key + 1}', 
                                      style: const TextStyle(
                                        color: AppColors.black, // black on yellow — optimal contrast always
                                        fontSize: 11, 
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // Stop name — loaded from cache, works offline
                                  title: Text(
                                    stop.name, 
                                    style: TextStyle(
                                      color: theme.textPrimary, // was AppColors.white — now theme-aware
                                      fontSize: 13,
                                    ),
                                  ),
                                  // Right arrow indicator
                                  trailing: const Icon(
                                    Icons.chevron_right, 
                                    color: AppColors.grey, // grey stays as static accent
                                    size: 18,
                                  ),
                                );
                              }).toList(),
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