// lib/screens/routes_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../models/route_detail_model.dart';
import '../widgets/stop_image_slideshow.dart';
import '../widgets/app_back_button.dart';
import 'route_detail_screen.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  // List to store all available tour routes
  List<RouteDetail> _routes = [];
  
  // Loading state to show spinner while fetching data
  bool _isLoading = true;
  
  // Error message to display if something goes wrong
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Fetch routes from backend when screen initializes
    _fetchRoutes();
  }

  // Fetch all available routes from the backend API
  Future<void> _fetchRoutes() async {
    // Reset state before fetching
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Make HTTP GET request to fetch routes
      final response = await http.get(Uri.parse('${AppConstants.baseUrl}/routes'));
      
      // Debug line - prints raw API response for troubleshooting
      // Remove this once the app is working correctly in production
      debugPrint('ROUTES RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        // Parse JSON response into RouteDetail model objects
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _routes = data.map((j) => RouteDetail.fromJson(j)).toList();
          _isLoading = false;
        });
      } else {
        // Handle non-200 responses from server
        setState(() {
          _errorMessage = 'Failed to load routes from server.';
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle network errors or JSON parsing errors
      setState(() {
        _errorMessage = 'Could not connect to network.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Available Routes'),
      ),
      body: _isLoading
          // Show loading spinner while fetching data
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.yellow),
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
                          style: const TextStyle(color: AppColors.grey), 
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Retry button to attempt fetching routes again
                        ElevatedButton(
                          onPressed: _fetchRoutes, 
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              // Display list of available routes
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _routes.length,
                  itemBuilder: (context, index) {
                    // Get current route details from the list
                    final routeDetail = _routes[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.black2,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.amber.withValues(alpha: 0.3),
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
                                          style: const TextStyle(
                                            color: AppColors.white, 
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
                                      color: AppColors.grey, 
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Auto-playing image slideshow of route stops
                                  if (routeDetail.stops.isNotEmpty) 
                                    StopImageSlideshow(route: routeDetail),
                                ],
                              ),
                            ),
                            
                            // Expandable section showing all stops on this route
                            // Expands in place instead of navigating to a separate screen
                            // Tapping an individual stop opens the full detail screen,
                            // automatically scrolled to that specific stop
                            ExpansionTile(
                              title: const Text(
                                'View Stops on this Route', 
                                style: TextStyle(
                                  color: AppColors.yellow, 
                                  fontSize: 13, 
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              iconColor: AppColors.yellow,
                              collapsedIconColor: AppColors.yellow,
                              children: routeDetail.stops.asMap().entries.map((entry) {
                                // entry.key = index, entry.value = TourStop object
                                final stop = entry.value;
                                
                                return ListTile(
                                  onTap: () {
                                    // Navigate to route detail screen, scrolled to this specific stop
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
                                    backgroundColor: AppColors.yellow,
                                    child: Text(
                                      '${entry.key + 1}', 
                                      style: const TextStyle(
                                        color: AppColors.black, 
                                        fontSize: 11, 
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // Stop name
                                  title: Text(
                                    stop.name, 
                                    style: const TextStyle(
                                      color: AppColors.white, 
                                      fontSize: 13,
                                    ),
                                  ),
                                  // Right arrow indicator
                                  trailing: const Icon(
                                    Icons.chevron_right, 
                                    color: AppColors.grey, 
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