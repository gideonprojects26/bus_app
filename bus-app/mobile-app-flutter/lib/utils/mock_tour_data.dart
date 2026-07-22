import '../models/tour_route_model.dart';

class MockTourData {
  static final List<TourRouteModel> tours = [
    TourRouteModel(
      id: 'city_tour',
      name: 'City Highlights Tour',
      description: 'Origin: BMK House to Independence Grounds\nDistance: 25.5 km | Duration: 240 mins\nPrice: UGX 50,000',
      stops: [
        TourStop(name: 'Serena Hotel', latitude: 0.3150, longitude: 32.5838),
        TourStop(name: 'Bank of Uganda', latitude: 0.3155, longitude: 32.5823),
        TourStop(name: 'Constitution Square', latitude: 0.3153, longitude: 32.5807),
        TourStop(name: 'Post Office', latitude: 0.3137, longitude: 32.5790),
        TourStop(name: 'Nakasero Market', latitude: 0.3162, longitude: 32.5765),
        TourStop(name: 'Clock Tower', latitude: 0.3111, longitude: 32.5750),
        TourStop(name: 'Ring Road', latitude: 0.3095, longitude: 32.5738),
        TourStop(name: 'Kabaka\'s Lake', latitude: 0.3068, longitude: 32.5602),
        TourStop(name: 'Bulange Parliament', latitude: 0.3077, longitude: 32.5588),
        TourStop(name: 'Lubaga Cathedral', latitude: 0.3037, longitude: 32.5536),
        TourStop(name: 'Namirembe Cathedral', latitude: 0.3085, longitude: 32.5557),
        TourStop(name: 'Café Javas Bakuli', latitude: 0.3128, longitude: 32.5687),
        TourStop(name: 'Kasubi Tombs', latitude: 0.3277, longitude: 32.5572),
        TourStop(name: 'Makerere University', latitude: 0.3350, longitude: 32.5675),
        TourStop(name: 'Uganda Museum', latitude: 0.3356, longitude: 32.5821),
        TourStop(name: 'Independence Grounds', latitude: 0.3162, longitude: 32.5860),
      ],
      schedule: [
        BusSchedule(day: 'Monday - Friday', departureTime: '08:00 AM'),
        BusSchedule(day: 'Saturday - Sunday', departureTime: '10:00 AM'),
      ],
    ),
    TourRouteModel(
      id: 'religious_tour', // This matches your color logic in tracking_screen.dart
      name: 'Religious Tour',
      description: 'Origin: BMK Café to Namugongo Martyrs Shrine\nDistance: 30.0 km | Duration: 180 mins\nPrice: UGX 40,000',
      stops: [
        TourStop(name: 'Lubaga Cathedral', latitude: 0.3037, longitude: 32.5536),
        TourStop(name: 'Namirembe Cathedral', latitude: 0.3085, longitude: 32.5557),
        TourStop(name: 'Gaddafi National Mosque', latitude: 0.3134, longitude: 32.5673),
        TourStop(name: 'Bahá\'í Temple', latitude: 0.3638, longitude: 32.5889),
        TourStop(name: 'Namugongo Martyrs Shrine', latitude: 0.3972, longitude: 32.6456),
      ],
      schedule: [
        BusSchedule(day: 'Sunday', departureTime: '09:00 AM'),
        BusSchedule(day: 'Wednesday', departureTime: '02:00 PM'),
      ],
    ),
  ];
}