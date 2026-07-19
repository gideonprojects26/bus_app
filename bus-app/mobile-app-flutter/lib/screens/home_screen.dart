import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
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

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Hi, ${authProvider.user?.fullName.split(' ').first ?? "Rider"}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.red),
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ImageCarousel(),
              const SizedBox(height: 24),
              const Text(
                'Quick Actions',
                style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w600),
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
