
class TourStop {
  final String name;
  final double latitude;
  final double longitude;

  TourStop({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

class BusSchedule {
  final String day;
  final String departureTime;

  BusSchedule({
    required this.day,
    required this.departureTime,
  });
}

class TourRouteModel {
  final String id;
  final String name;
  final String description;
  final List<TourStop> stops;
  final List<BusSchedule> schedule;

  TourRouteModel({
    required this.id,
    required this.name,
    required this.description,
    required this.stops,
    required this.schedule,
  });
}
