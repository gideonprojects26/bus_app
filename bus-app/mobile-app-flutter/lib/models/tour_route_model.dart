// Models for Tour Stops, Schedules, and Route Images with Captions

class RouteImage {
  final String path;
  final String caption;

  RouteImage({
    required this.path,
    required this.caption,
  });

  factory RouteImage.fromJson(Map<String, dynamic> json) {
    return RouteImage(
      path: json['path'] ?? '',
      caption: json['caption'] ?? '',
    );
  }
}

class TourStop {
  final String name;
  final double latitude;
  final double longitude;

  TourStop({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory TourStop.fromJson(Map<String, dynamic> json) {
    return TourStop(
      name: json['name'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class BusSchedule {
  final String day;
  final String departureTime;

  BusSchedule({
    required this.day,
    required this.departureTime,
  });

  factory BusSchedule.fromJson(Map<String, dynamic> json) {
    return BusSchedule(
      day: json['day'] ?? '',
      departureTime: json['departureTime'] ?? '',
    );
  }
}

class TourRouteModel {
  final String id;
  final String name;
  final String description;
  final String startPoint;
  final String endPoint;
  final double fare;
  final double internationalFare;
  final List<TourStop> stops;
  final List<BusSchedule> schedule;
  final List<RouteImage> images; // <--- Dynamic images array parsed from DB

  TourRouteModel({
    required this.id,
    required this.name,
    required this.description,
    required this.startPoint,
    required this.endPoint,
    required this.fare,
    required this.internationalFare,
    required this.stops,
    required this.schedule,
    required this.images,
  });

  factory TourRouteModel.fromJson(Map<String, dynamic> json) {
    return TourRouteModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      startPoint: json['startPoint'] ?? '',
      endPoint: json['endPoint'] ?? '',
      fare: double.tryParse(json['fare'].toString()) ?? 50000.0,
      internationalFare: double.tryParse(json['internationalFare'].toString()) ?? 30.0,
      stops: json['stops'] != null
          ? (json['stops'] as List).map((i) => TourStop.fromJson(i)).toList()
          : [],
      schedule: json['schedule'] != null
          ? (json['schedule'] as List).map((i) => BusSchedule.fromJson(i)).toList()
          : [],
      images: json['images'] != null
          ? (json['images'] as List).map((i) => RouteImage.fromJson(i)).toList()
          : [],
    );
  }
}