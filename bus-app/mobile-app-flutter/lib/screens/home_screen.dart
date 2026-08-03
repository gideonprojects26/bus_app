import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// ignore: unused_import
import 'dart:math';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../models/route_detail_model.dart';
import 'routes_screen.dart';
import 'tracking_screen.dart';
import 'booking_screen.dart';
import 'rent_bus_screen.dart';
import 'profile_screen.dart';
import 'help_support_screen.dart';
import 'route_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mixed list of stops from all routes (max 7 for display)
  List<_StopWithRoute> _popularStops = [];
  bool _isLoadingStops = true;

  @override
  void initState() {
    super.initState();
    _loadRoutesAndStops();
  }

  /// Fetches all routes from the backend, then builds a mixed list of stops
  /// by taking evenly from each route (round-robin) so popular stops section
  /// shows variety instead of just the first route's stops.
  Future<void> _loadRoutesAndStops() async {
    try {
      final response = await http.get(Uri.parse('${AppConstants.baseUrl}/routes'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final routes = data.map((j) => RouteDetail.fromJson(j)).toList();

        // Group stops with images by their parent route
        final List<List<_StopWithRoute>> stopsByRoute = [];
        for (final route in routes) {
          final routeStops = <_StopWithRoute>[];
          for (final stop in route.stops) {
            if (stop.primaryImage != null) {
              routeStops.add(_StopWithRoute(stop: stop, parentRoute: route));
            }
          }
          if (routeStops.isNotEmpty) {
            stopsByRoute.add(routeStops);
          }
        }

        // Round-robin: take one stop from each route, then repeat
        // This ensures stops are mixed from all routes evenly
        final List<_StopWithRoute> mixedStops = [];
        if (stopsByRoute.isNotEmpty) {
          int maxPerRoute = 7; // Safety limit per route
          // ignore: unused_local_variable
          int routeIndex = 0;
          List<int> takenCounts = List.filled(stopsByRoute.length, 0);

          while (mixedStops.length < 7) {
            bool addedAny = false;
            for (int i = 0; i < stopsByRoute.length; i++) {
              if (mixedStops.length >= 7) break;
              if (takenCounts[i] < stopsByRoute[i].length && takenCounts[i] < maxPerRoute) {
                mixedStops.add(stopsByRoute[i][takenCounts[i]]);
                takenCounts[i]++;
                addedAny = true;
              }
            }
            // If no more stops can be added from any route, exit
            if (!addedAny) break;
          }
        }

        if (mounted) {
          setState(() {
            _popularStops = mixedStops;
            _isLoadingStops = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingStops = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingStops = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = context.watch<ThemeProvider>();
    final firstName = authProvider.user?.fullName.split(' ').first ?? 'Rider';

    return Scaffold(
      backgroundColor: theme.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingScreen())),
        backgroundColor: AppColors.yellow,
        icon: const Icon(Icons.add_rounded, color: AppColors.black),
        elevation: 2,
        label: const Text('New Booking', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- HEADER ----------
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, $firstName',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: theme.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            Icon(Icons.location_on_rounded, color: AppColors.yellow, size: 16),
                            SizedBox(width: 4),
                            Text('Kampala, Central Region', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.person_outline, color: AppColors.yellow),
                      ),
                    ),
                  ],
                ),
              ),

              // ---------- HERO BANNER ----------
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    height: 180,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset('assets/images/bus1.jpg', fit: BoxFit.cover),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.black.withValues(alpha: 0.85), Colors.transparent],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'The Pearl of Africa',
                                  style: TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Explore Kampala in comfort.',
                                  style: TextStyle(color: AppColors.white, fontSize: 13),
                                ),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoutesScreen())),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                    decoration: BoxDecoration(color: AppColors.yellow, borderRadius: BorderRadius.circular(12)),
                                    child: const Text('Our Routes', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ---------- QUICK ACTIONS ----------
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.confirmation_number_rounded,
                        label: 'Book a Trip',
                        theme: theme,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingScreen())),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.map_rounded,
                        label: 'Live Location',
                        theme: theme,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackingScreen())),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.directions_bus_rounded,
                        label: 'Private Booking',
                        theme: theme,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RentBusScreen())),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.help_outline,
                        label: 'Help',
                        theme: theme,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
                      ),
                    ),
                  ],
                ),
              ),

              // ---------- POPULAR STOPS ----------
              _SectionHeader(title: 'Popular Stops', theme: theme),
              SizedBox(
                height: 240, // Increased from 210 to fit larger cards
                child: _isLoadingStops
                    ? const Center(child: CircularProgressIndicator(color: AppColors.yellow))
                    : _popularStops.isEmpty
                        ? Center(
                            child: Text(
                              'No stops available yet.',
                              style: TextStyle(color: theme.textPrimary, fontSize: 13),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _popularStops.length,
                            itemBuilder: (context, index) {
                              final item = _popularStops[index];
                              return _StopCard(
                                stop: item.stop,
                                parentRoute: item.parentRoute,
                                theme: theme,
                              );
                            },
                          ),
              ),
              const SizedBox(height: 20),

              // ---------- RENT THE BUS PREVIEW ----------
              _SectionHeader(title: 'Need a Private Bus?', theme: theme),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.amber.withValues(alpha: 0.25)),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(color: theme.background, borderRadius: BorderRadius.circular(12)),
                            alignment: Alignment.center,
                            child: const Icon(Icons.airport_shuttle_rounded, color: AppColors.yellow, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Group & Private Rentals', style: TextStyle(color: theme.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                                const Text('For weddings, corporate events, and groups', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RentBusScreen())),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.yellow),
                            foregroundColor: AppColors.yellow,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Request Custom Quote', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple data class to bundle a TourStop with its parent RouteDetail
/// so we can navigate to the correct route when a stop is tapped.
class _StopWithRoute {
  final TourStop stop;
  final RouteDetail parentRoute;

  const _StopWithRoute({required this.stop, required this.parentRoute});
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeProvider theme;

  const _SectionHeader({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Text(title, style: TextStyle(color: theme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
    );
  }
}

/// Circular quick-action button with an icon above a label.
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeProvider theme;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.theme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: AppColors.yellow, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: theme.textPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Horizontal card displaying a popular stop — image fills the entire card
/// with the stop name overlaid as a caption at the bottom.
/// Tapping navigates to the RouteDetailScreen scrolled to this stop.
class _StopCard extends StatelessWidget {
  final TourStop stop;
  final RouteDetail parentRoute;
  final ThemeProvider theme;

  const _StopCard({required this.stop, required this.parentRoute, required this.theme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RouteDetailScreen(
              route: parentRoute,
              targetStopId: stop.id,
            ),
          ),
        );
      },
      child: Container(
        width: 240, // Increased from 220
        height: 200, // Full card height — image fills it all
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.amber.withValues(alpha: 0.25)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image fills the entire card
              stop.primaryImage != null
                  ? Image.network(
                      stop.primaryImage!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: theme.surfaceElevated,
                          child: const Center(
                            child: CircularProgressIndicator(color: AppColors.yellow, strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: theme.surfaceElevated,
                          child: const Icon(Icons.image, color: AppColors.grey, size: 40),
                        );
                      },
                    )
                  : Container(
                      color: theme.surfaceElevated,
                      child: const Icon(Icons.image, color: AppColors.grey, size: 40),
                    ),

              // Stop name caption at the bottom — clean, no dark overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Text(
                    stop.name,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}