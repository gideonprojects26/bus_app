import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils/app_colors.dart';
import '../utils/mock_tour_data.dart';
import '../utils/mock_bus_eta_data.dart';
import '../models/tour_route_model.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_card_shadow.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  String? _selectedRouteId;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(0.3163, 32.5822),
    zoom: 12,
  );

  Set<Marker> _buildMarkers(TourRouteModel tour) {
    return tour.stops.map((stop) {
      return Marker(
        markerId: MarkerId(stop.name),
        position: LatLng(stop.latitude, stop.longitude),
        infoWindow: InfoWindow(title: stop.name),
      );
    }).toSet();
  }

  Set<Polyline> _buildPolyline(TourRouteModel tour) {
    final color = tour.id == 'religious_tour' ? AppColors.yellow : AppColors.red;
    return {
      Polyline(
        polylineId: PolylineId(tour.id),
        points: tour.stops.map((s) => LatLng(s.latitude, s.longitude)).toList(),
        color: color,
        width: 4,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final selectedTour = _selectedRouteId == null
        ? null
        : MockTourData.tours.firstWhere((t) => t.id == _selectedRouteId);

    final screenHeight = MediaQuery.of(context).size.height;
    // Map occupies two-thirds of the available screen height, as requested.
    final mapHeight = screenHeight * (1 / 2);

    final visibleBuses = _selectedRouteId == null
        ? MockBusEtaData.buses
        : MockBusEtaData.buses.where((b) => b.routeId == _selectedRouteId).toList();

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Track Bus'),
      ),
      body: Column(
        children: [
          // MAP SECTION — enclosed in a rounded, bordered container
          // occupying 2/3 of the screen height rather than the full screen.
          SizedBox(
            height: mapHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.amber.withValues(alpha: 0.35), width: 1.5),
                  ),
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: _initialPosition,
                        markers: selectedTour != null ? _buildMarkers(selectedTour) : {},
                        polylines: selectedTour != null ? _buildPolyline(selectedTour) : {},
                      ),
                      Positioned(
                        top: 14,
                        right: 14,
                        child: Column(
                          children: [
                            _RouteToggleChip(
                              label: 'All',
                              isSelected: _selectedRouteId == null,
                              onTap: () => setState(() => _selectedRouteId = null),
                            ),
                            const SizedBox(height: 8),
                            ...MockTourData.tours.map((tour) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: _RouteToggleChip(
                                  label: tour.name,
                                  isSelected: _selectedRouteId == tour.id,
                                  onTap: () => setState(() => _selectedRouteId = tour.id),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ETA PANEL — bottom third of the screen, listing each bus's
          // estimated time of arrival at its next stop.
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              decoration: const BoxDecoration(
                color: AppColors.black3,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Live Bus Arrival Times',
                    style: TextStyle(color: AppColors.white, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Estimated time for each bus to reach its next stop',
                    style: TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView.builder(
                      itemCount: visibleBuses.length,
                      itemBuilder: (context, index) {
                        final bus = visibleBuses[index];
                        return _BusEtaTile(bus: bus);
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

class _RouteToggleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RouteToggleChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.yellow : AppColors.black.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.yellow),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.black : AppColors.yellow,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _BusEtaTile extends StatelessWidget {
  final dynamic bus;

  const _BusEtaTile({required this.bus});

  @override
  Widget build(BuildContext context) {
    final isArrivingSoon = bus.etaMinutes <= 10;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.black2,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppCardShadow.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (isArrivingSoon ? AppColors.yellow : AppColors.grey).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_bus_rounded,
              color: isArrivingSoon ? AppColors.yellow : AppColors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bus.plateNumber,
                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  '${bus.routeName} · Next: ${bus.nextStop}',
                  style: const TextStyle(color: AppColors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${bus.etaMinutes} min',
                style: TextStyle(
                  color: isArrivingSoon ? AppColors.yellow : AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Text('ETA', style: TextStyle(color: AppColors.grey, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}