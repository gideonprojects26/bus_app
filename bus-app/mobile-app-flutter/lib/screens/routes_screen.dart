import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/backend_route_model.dart';
import '../services/route_service.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_card_shadow.dart';
import 'booking_screen.dart';
import '../widgets/stop_image_slideshow.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  List<BackendRoute> _routes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    try {
      final routes = await RouteService.fetchRoutes();
      setState(() {
        _routes = routes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load available tours. Check your connection.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Available Tours'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.yellow))
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_errorMessage!, style: const TextStyle(color: AppColors.grey), textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(onPressed: _loadRoutes, child: const Text('Retry')),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _routes.length,
                    itemBuilder: (context, index) {
                      final tour = _routes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _TourCard(tour: tour),
                            const SizedBox(height: 10),
                            StopImageSlideshow(routeName: tour.name, stopCount: tour.stops.length),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class _TourCard extends StatelessWidget {
  final BackendRoute tour;

  const _TourCard({required this.tour});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
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
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                tour.description,
                style: const TextStyle(color: AppColors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.confirmation_number_outlined, size: 14, color: AppColors.yellow),
                  const SizedBox(width: 6),
                  Text(
                    'UGX ${tour.fare.toStringAsFixed(0)} / \$${tour.internationalFare.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppColors.yellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          iconColor: AppColors.yellow,
          collapsedIconColor: AppColors.yellow,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 8),
                  const Text('Stops', style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...tour.stops.asMap().entries.map((entry) {
                    final stopName = entry.value['name'];
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
                          Expanded(
                            child: Text(
                              stopName,
                              style: const TextStyle(color: AppColors.white, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 14),
                  const Text('Daily Departures', style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: tour.schedule.map((time) {
                      final timeStr = time['departureTime'] ?? '';
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.black2,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          timeStr,
                          style: const TextStyle(color: AppColors.white, fontSize: 12),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
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