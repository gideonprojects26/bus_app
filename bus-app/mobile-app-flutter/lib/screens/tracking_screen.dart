import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import '../utils/stop_coordinates.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_card_shadow.dart';

/// Screen displaying an interactive Google Map with tour route stops,
/// polylines connecting them, and a bottom timeline panel listing all stops.
/// Supports toggling between different routes, focusing on individual stops,
/// and expanding the map to full screen.
///
/// THEME: Converted to be theme-aware (light/dark). Uses ThemeProvider for
/// surface colors and text colors instead of hardcoded AppColors.black2/black3/white.
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  // Currently selected route ID (defaults to City Highlights)
  String _selectedRouteId = 'city_highlights';
  GoogleMapController? _mapController;

  // Controls whether the map is in full-screen expanded mode
  bool _isMapExpanded = false;

  // Camera initial view over central Kampala
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(0.3182, 32.5898),
    zoom: 12.5,
  );

  /// Helper to get the currently selected tour route model
  TourRouteData get _selectedRoute {
    return StopTrackingData.routes.firstWhere(
      (r) => r.id == _selectedRouteId,
      orElse: () => StopTrackingData.routes.first,
    );
  }

  /// Builds map markers for all stops in the active route
  Set<Marker> _buildMarkers(TourRouteData route) {
    return route.stops.map((stop) {
      return Marker(
        markerId: MarkerId(stop.id),
        position: stop.location,
        infoWindow: InfoWindow(
          title: stop.name,
          snippet: stop.subtitle,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            route.id == 'religious_tour'
              ? BitmapDescriptor.hueYellow
              : BitmapDescriptor.hueRed,
        ),
      );
    }).toSet();
  }

  /// Builds sequential route polylines connecting stops
  Set<Polyline> _buildPolyline(TourRouteData route) {
    return {
      Polyline(
        polylineId: PolylineId(route.id),
        points: route.stops.map((s) => s.location).toList(),
        color: route.id == 'religious_tour' ? AppColors.yellow : AppColors.amber,
        width: 4,
      ),
    };
  }

  /// Recenters the map view to fit all markers in the active route
  void _recenterMap(TourRouteData route) {
    if (_mapController == null || route.stops.isEmpty) return;

    double minLat = route.stops.first.latitude;
    double maxLat = route.stops.first.latitude;
    double minLng = route.stops.first.longitude;
    double maxLng = route.stops.first.longitude;

    for (final stop in route.stops) {
      if (stop.latitude < minLat) minLat = stop.latitude;
      if (stop.latitude > maxLat) maxLat = stop.latitude;
      if (stop.longitude < minLng) minLng = stop.longitude;
      if (stop.longitude > maxLng) maxLng = stop.longitude;
    }

    // Handles single stop or identical bounds safely without throwing bounds assertions
    if (minLat == maxLat && minLng == maxLng) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(minLat, minLng), 15.0),
      );
    } else {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          50.0, // padding
        ),
      );
    }
  }

  /// Zooms camera directly to a selected stop when tapped in the timeline list
  void _focusStop(LatLng location) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 15.5),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final route = _selectedRoute;
    // Access theme provider for light/dark mode aware colors
    final theme = context.watch<ThemeProvider>();
    
    // Calculate map height: full screen when expanded, ~48% otherwise
    final screenHeight = MediaQuery.of(context).size.height;
    final mapHeight = _isMapExpanded ? screenHeight : screenHeight * 0.48;

    return Scaffold(
      backgroundColor: theme.background, // now theme-aware
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Track Tour Route'),
      ),
      body: Column(
        children: [
          // MAP CONTAINER
          SizedBox(
            height: mapHeight,
            child: Padding(
              padding: _isMapExpanded
                  ? EdgeInsets.zero // No padding when full screen
                  : const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: ClipRRect(
                borderRadius: _isMapExpanded
                    ? BorderRadius.zero // No rounded corners when full screen
                    : BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: _isMapExpanded
                        ? BorderRadius.zero
                        : BorderRadius.circular(20),
                    border: _isMapExpanded
                        ? null // No border when full screen
                        : Border.all(
                            color: AppColors.amber.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                  ),
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: _initialPosition,
                        onMapCreated: (controller) {
                          _mapController = controller;
                          // Recenter camera on the active route as soon as map finishes loading
                          _recenterMap(route);
                        },
                        markers: _buildMarkers(route),
                        polylines: _buildPolyline(route),
                      ),

                      // EXPAND / COLLAPSE BUTTON AT TOP LEFT
                      Positioned(
                        top: 12,
                        left: 12,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _isMapExpanded = !_isMapExpanded);
                            // Recenter map after transition completes
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _recenterMap(route);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.black.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.yellow),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isMapExpanded
                                      ? Icons.close_fullscreen_rounded
                                      : Icons.fullscreen_rounded,
                                  color: AppColors.yellow,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isMapExpanded ? 'Back' : 'Expand',
                                  style: const TextStyle(
                                    color: AppColors.yellow,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ROUTE TOGGLE CHIPS AT TOP RIGHT
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: StopTrackingData.routes.map((r) {
                            final isSelected = r.id == _selectedRouteId;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _selectedRouteId = r.id);
                                  _recenterMap(r);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.yellow
                                        : AppColors.black.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.yellow),
                                  ),
                                  child: Text(
                                    r.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.black
                                          : AppColors.yellow,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // STOPS TIMELINE PANEL — hidden when map is expanded
          if (!_isMapExpanded)
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                decoration: BoxDecoration(
                  color: theme.surfaceElevated, // was AppColors.black3 — now theme-aware
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.name,
                      style: TextStyle(
                        color: theme.textPrimary, // was AppColors.white — now theme-aware
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${route.stops.length} Stops · ${route.description}',
                      style: const TextStyle(
                        color: AppColors.grey, // grey stays as static accent
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),

                    // STOP LIST
                    Expanded(
                      child: ListView.builder(
                        itemCount: route.stops.length,
                        itemBuilder: (context, index) {
                          final stop = route.stops[index];
                          final isLast = index == route.stops.length - 1;

                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Step Number & Dynamically Scaling Timeline Line
                                Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: AppColors.yellow, // yellow stays as brand accent
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: AppColors.black, // black on yellow — optimal contrast always
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (!isLast)
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          color: AppColors.yellow.withValues(alpha: 0.35), // yellow stays as brand accent
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 12),

                                // Interactive Stop Details Card
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: GestureDetector(
                                      onTap: () => _focusStop(stop.location),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: theme.surface, // was AppColors.black2 — now theme-aware
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: AppCardShadow.soft,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    stop.name,
                                                    style: TextStyle(
                                                      color: theme.textPrimary, // was AppColors.white — now theme-aware
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    stop.subtitle,
                                                    style: const TextStyle(
                                                      color: AppColors.grey, // grey stays as static accent
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              '${stop.latitude.toStringAsFixed(3)}, ${stop.longitude.toStringAsFixed(3)}',
                                              style: const TextStyle(
                                                color: AppColors.amber, // amber stays as static accent
                                                fontSize: 10,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}