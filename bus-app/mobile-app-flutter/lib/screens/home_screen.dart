import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
// ignore: unused_import
import '../utils/constants.dart';
import '../models/backend_route_model.dart';
import '../services/route_service.dart';
import 'routes_screen.dart';
import 'tracking_screen.dart';
import 'booking_screen.dart';
import 'rent_bus_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BackendRoute> _popularRoutes = [];
  bool _isLoadingRoutes = true;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    try {
      final routes = await RouteService.fetchRoutes();
      if (mounted) {
        setState(() {
          _popularRoutes = routes;
          _isLoadingRoutes = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingRoutes = false);
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
                        // ignore: prefer_const_constructors
                        Row(
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            const Icon(Icons.location_on_rounded, color: AppColors.yellow, size: 16),
                            const SizedBox(width: 4),
                            const Text('Kampala, Central Region', style: TextStyle(color: AppColors.grey, fontSize: 12)),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.directions_bus_rounded,
                        label: 'Rent Bus',
                        theme: theme,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RentBusScreen())),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.map_rounded,
                        label: 'Live Track',
                        theme: theme,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackingScreen())),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.confirmation_number_rounded,
                        label: 'Book',
                        theme: theme,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingScreen())),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.route_rounded,
                        label: 'Routes',
                        theme: theme,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoutesScreen())),
                      ),
                    ),
                  ],
                ),
              ),

              // ---------- POPULAR ROUTES ----------
              _SectionHeader(title: 'Popular Routes', theme: theme),
              SizedBox(
                height: 190,
                child: _isLoadingRoutes
                    ? const Center(child: CircularProgressIndicator(color: AppColors.yellow))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _popularRoutes.length,
                        itemBuilder: (context, index) {
                          final route = _popularRoutes[index];
                          return _RouteCard(
                            route: route,
                            theme: theme,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => BookingScreen(preselectedRouteId: route.id)),
                            ),
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
              borderRadius: BorderRadius.circular(16),
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

class _RouteCard extends StatelessWidget {
  final BackendRoute route;
  final ThemeProvider theme;
  final VoidCallback onTap;

  const _RouteCard({required this.route, required this.theme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: Image.asset('assets/images/bus2.jpg', fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(route.name, style: TextStyle(color: theme.textPrimary, fontSize: 13, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('UGX ${route.fare.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.yellow, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}