class BackendRoute {
  final String id;
  final String name;
  final String description;
  final String startPoint;
  final String endPoint;
  final double fare;
  final double internationalFare;
  final List<Map<String, dynamic>> stops;
  final List<Map<String, dynamic>> schedule;

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
  });

  factory BackendRoute.fromJson(Map<String, dynamic> json) {
    return BackendRoute(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      startPoint: json['startPoint'],
      endPoint: json['endPoint'],
      fare: double.parse(json['fare'].toString()),
      internationalFare: double.parse((json['internationalFare'] ?? 30).toString()),
      stops: List<Map<String, dynamic>>.from(json['stops'] ?? []),
      schedule: List<Map<String, dynamic>>.from(json['schedule'] ?? []),
    );
  }
}