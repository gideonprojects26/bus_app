import 'tour_route_model.dart'; // Imports RouteImage model

class BackendRoute {
  final String id;
  final String name;
  final String description;
  final String startPoint;
  final String endPoint;
  final double fare;
  final double internationalFare;
  final List<dynamic> stops;
  final List<dynamic> schedule;
  final List<RouteImage> images; // <--- 1. Add images field

  BackendRoute({
    required this.id,
    required this.name,
    required this.description,
    required this.startPoint,
    required this.endPoint,
    required this.fare,
    required this.internationalFare,
    required this.stops,
    required this.schedule,
    required this.images, // <--- 2. Add to constructor
  });

  factory BackendRoute.fromJson(Map<String, dynamic> json) {
    return BackendRoute(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      startPoint: json['startPoint'] ?? '',
      endPoint: json['endPoint'] ?? '',
      fare: double.tryParse(json['fare'].toString()) ?? 50000.0,
      internationalFare: double.tryParse(json['internationalFare'].toString()) ?? 30.0,
      stops: json['stops'] ?? [],
      schedule: json['schedule'] ?? [],
      images: json['images'] != null
          ? (json['images'] as List)
              .map((item) => RouteImage.fromJson(item as Map<String, dynamic>))
              .toList()
          : [], // <--- 3. Parse images array from JSON
    );
  }
}