import '../models/tour_route_model.dart';
import '../models/stop_model.dart';
import '../models/schedule_model.dart';

// TEMPORARY mock data — replace with real API calls once
// the backend Routes endpoint is built.
class MockTourData {
  static List<TourRouteModel> tours = [
    TourRouteModel(
      id: 'religious_tour',
      name: 'Religious Tour',
      description: 'Visit the historic religious sites of Kampala.',
      stops: [
        StopModel(name: 'Kampala Central', latitude: 0.3163, longitude: 32.5822),
        StopModel(name: 'Rubaga Cathedral', latitude: 0.3050, longitude: 32.5560),
        StopModel(name: 'Namirembe Cathedral', latitude: 0.3181, longitude: 32.5691),
        StopModel(name: 'Munyonyo Martyrs Shrine', latitude: 0.2725, longitude: 32.6280),
        StopModel(name: 'Namugongo Martyrs Shrine', latitude: 0.3833, longitude: 32.6706),
      ],
      schedule: [
        ScheduleModel(day: 'Monday', departureTime: '08:00'),
        ScheduleModel(day: 'Wednesday', departureTime: '08:00'),
        ScheduleModel(day: 'Friday', departureTime: '08:00'),
      ],
    ),
    TourRouteModel(
      id: 'city_highlights_tour',
      name: 'City Highlights Tour',
      description: 'Explore the best of Kampala in one trip.',
      stops: [
        StopModel(name: 'Kampala City Center', latitude: 0.3163, longitude: 32.5822),
        StopModel(name: 'Uganda Museum', latitude: 0.3316, longitude: 32.5851),
        StopModel(name: 'Kasubi Tombs', latitude: 0.3251, longitude: 32.5522),
        StopModel(name: 'Independence Monument', latitude: 0.3145, longitude: 32.5811),
        StopModel(name: 'Owino Market', latitude: 0.3068, longitude: 32.5744),
      ],
      schedule: [
        ScheduleModel(day: 'Daily', departureTime: '09:00'),
        ScheduleModel(day: 'Daily', departureTime: '14:00'),
      ],
    ),
  ];
}
