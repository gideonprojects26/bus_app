import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/image_carousel.dart';
import '../widgets/quick_action_button.dart';
import 'routes_screen.dart';
import 'tracking_screen.dart';
import 'booking_screen.dart';
import 'rent_bus_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.background,
        title: Text(
          'Hi, ${authProvider.user?.fullName.split(' ').first ?? "Rider"}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: theme.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ImageCarousel(),
              const SizedBox(height: 24),
              Text(
                'Quick Actions',
                style: TextStyle(color: theme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.3,
                children: [
                  QuickActionButton(
                    imagePath: 'assets/images/book.png',
                    label: 'Book Yourself a Tour',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BookingScreen()),
                    ),
                  ),
                  QuickActionButton(
                    imagePath: 'assets/images/tour.png',
                    label: 'Our Tour Routes',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RoutesScreen()),
                    ),
                  ),
                  QuickActionButton(
                    imagePath: 'assets/images/track.png',
                    label: 'Tour Bus Locations',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TrackingScreen()),
                    ),
                  ),
                  QuickActionButton(
                    imagePath: 'assets/images/rent.png',
                    label: 'Rent the Bus',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RentBusScreen()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}