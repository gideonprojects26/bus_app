import '../models/bus_eta_model.dart';

// TEMPORARY mock data representing 4 buses (2 per tour route) and their
// estimated time of arrival at their next stop. Replace with a real API
// call to GET /api/buses (with live currentLat/currentLng) once the
// backend is tracking actual bus positions.
class MockBusEtaData {
  static List<BusEtaModel> buses = [
    BusEtaModel(
      busId: 'bus_1',
      plateNumber: 'UBA 214K',
      routeId: 'religious_tour',
      routeName: 'Religious Tour',
      nextStop: 'Rubaga Cathedral',
      etaMinutes: 8,
    ),
    BusEtaModel(
      busId: 'bus_2',
      plateNumber: 'UBB 552M',
      routeId: 'religious_tour',
      routeName: 'Religious Tour',
      nextStop: 'Namugongo Martyrs Shrine',
      etaMinutes: 22,
    ),
    BusEtaModel(
      busId: 'bus_3',
      plateNumber: 'UBC 903L',
      routeId: 'city_highlights_tour',
      routeName: 'City Highlights Tour',
      nextStop: 'Uganda Museum',
      etaMinutes: 5,
    ),
    BusEtaModel(
      busId: 'bus_4',
      plateNumber: 'UBD 771N',
      routeId: 'city_highlights_tour',
      routeName: 'City Highlights Tour',
      nextStop: 'Owino Market',
      etaMinutes: 14,
    ),
  ];
}