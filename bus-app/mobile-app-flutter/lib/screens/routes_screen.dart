import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/mock_tour_data.dart';
import '../models/tour_route_model.dart';
import 'booking_screen.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_card_shadow.dart';

class RoutesScreen extends StatelessWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  leading: const AppBackButton(),
  title: const Text('Available Tours'),
),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: MockTourData.tours.length,
          itemBuilder: (context, index) {
            final tour = MockTourData.tours[index];
            return _TourCard(tour: tour);
          },
        ),
      ),
    );
  }
}

class _TourCard extends StatelessWidget {
  final TourRouteModel tour;

  const _TourCard({required this.tour});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        boxShadow: AppCardShadow.soft,
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            tour.name,
            style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            tour.description,
            style: const TextStyle(color: AppColors.grey, fontSize: 12),
          ),
          iconColor: AppColors.yellow,
          collapsedIconColor: AppColors.yellow,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Stops', style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...tour.stops.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: AppColors.yellow,
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(color: AppColors.black, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(entry.value.name, style: const TextStyle(color: AppColors.white)),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 14),
                  const Text('Bus Schedule', style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...tour.schedule.map((s) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(s.day, style: const TextStyle(color: AppColors.white)),
                          Text(s.departureTime, style: const TextStyle(color: AppColors.grey)),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingScreen(preselectedRouteId: tour.id),
                          ),
                        );
                      },
                      child: const Text('Book This Tour'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
