import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  // Flattened list of all stops across all routes (max 7 for display)
  List<_StopWithRoute> _popularStops = [];
  bool _isLoadingStops = true;

  @override
  void initState() {
    super.initState();
    _loadRoutesAndStops();
  }

  /// Fetches all routes from the backend, then flattens their stops
  /// into a single list. Each stop keeps a reference to its parent route
  /// so we can navigate to the correct RouteDetailScreen on tap.
  Future<void> _loadRoutesAndStops() async {
    try {
      final response = await http.get(Uri.parse('${AppConstants.baseUrl}/routes'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final routes = data.map((j) => RouteDetail.fromJson(j)).toList();

        // Flatten all stops from all routes, keeping track of which route they belong to
        final List<_StopWithRoute> allStops = [];
        for (final route in routes) {
          for (final stop in route.stops) {
            // Only include stops that have at least one image
            if (stop.primaryImage != null) {
              allStops.add(_StopWithRoute(stop: stop, parentRoute: route));
            }
          }
        }

        // Take at most 7 stops for the popular section
        final popularStops = allStops.take(7).toList();

        if (mounted) {
          setState(() {
            _popularStops = popularStops;
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
                        // Now a const Row since all children are const
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
                                    child: const Text('Book Now', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 13)),
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
              // Order: Book a Trip → Live Location → Private Booking → Help & Support
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
                height: 210,
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
/// Now uses BoxShape.circle for a fully round icon container.
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
              shape: BoxShape.circle, // was BorderRadius.circular(16) — now fully circular
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

/// Horizontal card displaying a popular stop with its image and name.
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
        // Navigate to route detail screen, auto-scrolled to this specific stop
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
        width: 220,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.amber.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stop image — uses primaryImage (first image), falls back to placeholder
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: SizedBox(
                height: 130,
                width: double.infinity,
                child: stop.primaryImage != null
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
              ),
            ),
            // Stop name
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                stop.name,
                style: TextStyle(color: theme.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}