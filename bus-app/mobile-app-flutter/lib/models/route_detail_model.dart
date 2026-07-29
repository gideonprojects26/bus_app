// lib/models/route_detail_model.dart

class TourStop {
  final int id;
  final String name;
  final String description;
  final List<String> images; // Supports multiple Cloudinary image URLs for the stop carousel
  final int orderIndex;

  TourStop({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.orderIndex,
  });

  factory TourStop.fromJson(Map<String, dynamic> json) {
    // Smart image parser: Handles an array of images (images: [...]), 
    // or falls back safely to single image string keys ('image' or 'imageUrl')
    List<String> parsedImages = [];

    if (json['images'] is List) {
      parsedImages = (json['images'] as List)
          .where((img) => img != null && img.toString().isNotEmpty)
          .map((img) => img.toString())
          .toList();
    } else if (json['image'] != null && json['image'].toString().isNotEmpty) {
      parsedImages = [json['image'].toString()];
    } else if (json['imageUrl'] != null && json['imageUrl'].toString().isNotEmpty) {
      parsedImages = [json['imageUrl'].toString()];
    }

    return TourStop(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unnamed Stop',
      description: json['description'] ?? 'No description available.',
      images: parsedImages,
      orderIndex: json['orderIndex'] ?? 0,
    );
  }

  // Helper getter: Returns the first image URL or null if no images exist
  String? get primaryImage => images.isNotEmpty ? images.first : null;
}

class RouteDetail {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final double fare;
  final List<TourStop> stops;

  RouteDetail({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.fare,
    required this.stops,
  });

  factory RouteDetail.fromJson(Map<String, dynamic> json) {
    var stopsList = (json['stops'] as List? ?? [])
        .map((s) => TourStop.fromJson(s))
        .toList();

    return RouteDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image'],
      fare: double.tryParse(json['fare'].toString()) ?? 0.0,
      stops: stopsList,
    );
  }
}