// lib/models/route_detail_model.dart

class TourStop {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final int orderIndex;

  TourStop({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.orderIndex,
  });

  factory TourStop.fromJson(Map<String, dynamic> json) {
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
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unnamed Stop',
      description: json['description'] ?? 'No description available.',
      images: parsedImages,
      orderIndex: json['orderIndex'] ?? 0,
    );
  }

  String? get primaryImage => images.isNotEmpty ? images.first : null;
}

class RouteDetail {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final double fare;
  final double internationalFare;
  final List<TourStop> stops;

  RouteDetail({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.fare,
    required this.internationalFare,
    required this.stops,
  });

  factory RouteDetail.fromJson(Map<String, dynamic> json) {
    var stopsList = (json['stops'] as List? ?? [])
        .map((s) => TourStop.fromJson(s))
        .toList();

    // Route banners are stored as an array of {path, caption} objects
    // on the backend; this pulls the first banner's path as the
    // header image, falling back to older single-image key names.
    String? bannerUrl;
    if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      final firstBanner = (json['images'] as List).first;
      bannerUrl = firstBanner is Map ? firstBanner['path']?.toString() : firstBanner.toString();
    } else {
      bannerUrl = json['imageUrl'] ?? json['image'];
    }

    return RouteDetail(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: bannerUrl,
      fare: double.tryParse(json['fare'].toString()) ?? 0.0,
      internationalFare: double.tryParse((json['internationalFare'] ?? 30).toString()) ?? 30.0,
      stops: stopsList,
    );
  }
}