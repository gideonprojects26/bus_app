import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Represents an individual stop along a tour route with precise coordinates.
class TourStopCoordinate {
  final String id;
  final String name;
  final String subtitle;
  final double latitude;
  final double longitude;

  const TourStopCoordinate({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
  });

  /// Helper getter returning Google Maps LatLng
  LatLng get location => LatLng(latitude, longitude);
}

/// Represents a complete tour route with a collection of ordered stops.
class TourRouteData {
  final String id;
  final String name;
  final String description;
  final List<TourStopCoordinate> stops;

  const TourRouteData({
    required this.id,
    required this.name,
    required this.description,
    required this.stops,
  });
}

/// Master dataset containing exact GPS coordinates for Kampala tour stops.
class StopTrackingData {
  static const List<TourRouteData> routes = [
    // ------------------------------------------------------------------
    // 1. CITY HIGHLIGHTS TOUR
    // ------------------------------------------------------------------
    TourRouteData(
      id: 'city_highlights',
      name: 'City Highlights Tour',
      description: 'Standard Kampala Sightseeing tour covering historical landmarks, royal grounds, and commercial centers.',
      stops: [
        TourStopCoordinate(
          id: 'ch_1',
          name: 'BMK House',
          subtitle: 'Starting Point (Colville Street / Wampewo Ave)',
          latitude: 0.3182,
          longitude: 32.5898,
        ),
        TourStopCoordinate(
          id: 'ch_2',
          name: 'Serena & Speke Hotel Area',
          subtitle: 'City Centre Hub',
          latitude: 0.3185,
          longitude: 32.5866,
        ),
        TourStopCoordinate(
          id: 'ch_3',
          name: 'Bank of Uganda & Kampala Road',
          subtitle: 'Financial District',
          latitude: 0.3145,
          longitude: 32.5802,
        ),
        TourStopCoordinate(
          id: 'ch_4',
          name: 'Constitution Square',
          subtitle: 'Kampala Boulevard',
          latitude: 0.3138,
          longitude: 32.5815,
        ),
        TourStopCoordinate(
          id: 'ch_5',
          name: 'Post Office Building',
          subtitle: 'General Post Office',
          latitude: 0.3134,
          longitude: 32.5830,
        ),
        TourStopCoordinate(
          id: 'ch_6',
          name: 'Nakasero Market Area',
          subtitle: 'Entebbe Road junction',
          latitude: 0.3105,
          longitude: 32.5785,
        ),
        TourStopCoordinate(
          id: 'ch_7',
          name: 'Clock Tower & Kibuye Market',
          subtitle: 'Southern Transit Corridor',
          latitude: 0.3015,
          longitude: 32.5746,
        ),
        TourStopCoordinate(
          id: 'ch_8',
          name: 'Ring Road',
          subtitle: 'Mengo Bypass',
          latitude: 0.2995,
          longitude: 32.5650,
        ),
        TourStopCoordinate(
          id: 'ch_9',
          name: "Kabaka's Lake & Lubiri Palace",
          subtitle: "King's Palace Grounds",
          latitude: 0.2986,
          longitude: 32.5600,
        ),
        TourStopCoordinate(
          id: 'ch_10',
          name: 'The Royal Mile & Bulange',
          subtitle: 'Buganda Parliament',
          latitude: 0.3080,
          longitude: 32.5535,
        ),
        TourStopCoordinate(
          id: 'ch_11',
          name: 'Lubaga & Namirembe Cathedrals',
          subtitle: 'Historic Hilltop Cathedrals',
          latitude: 0.3025,
          longitude: 32.5528,
        ),
        TourStopCoordinate(
          id: 'ch_12',
          name: 'Café Javas - Bakuli',
          subtitle: 'Refreshment Stop',
          latitude: 0.3175,
          longitude: 32.5630,
        ),
        TourStopCoordinate(
          id: 'ch_13',
          name: 'Kasubi Tombs',
          subtitle: 'UNESCO World Heritage Site',
          latitude: 0.3328,
          longitude: 32.5531,
        ),
        TourStopCoordinate(
          id: 'ch_14',
          name: 'Makerere / Wandegeya / Mulago',
          subtitle: 'Educational & Healthcare Belt',
          latitude: 0.3340,
          longitude: 32.5730,
        ),
        TourStopCoordinate(
          id: 'ch_15',
          name: 'Uganda Museum & Acacia Mall',
          subtitle: 'Cultural & Shopping District',
          latitude: 0.3361,
          longitude: 32.5822,
        ),
        TourStopCoordinate(
          id: 'ch_16',
          name: 'Independence Grounds',
          subtitle: 'Kololo Airstrip',
          latitude: 0.3262,
          longitude: 32.5938,
        ),
        TourStopCoordinate(
          id: 'ch_17',
          name: 'BMK House',
          subtitle: 'Tour End Point',
          latitude: 0.3182,
          longitude: 32.5898,
        ),
      ],
    ),

    // ------------------------------------------------------------------
    // 2. RELIGIOUS TOUR
    // ------------------------------------------------------------------
    TourRouteData(
      id: 'religious_tour',
      name: 'Religious Tour',
      description: 'Journey across major shrines, cathedrals, temples, and mosques in Kampala.',
      stops: [
        TourStopCoordinate(
          id: 'rel_1',
          name: 'BMK Cafe',
          subtitle: 'Starting Point',
          latitude: 0.3182,
          longitude: 32.5898,
        ),
        TourStopCoordinate(
          id: 'rel_2',
          name: 'Lubaga Cathedral',
          subtitle: 'Catholic Archdiocese Seat',
          latitude: 0.3025,
          longitude: 32.5528,
        ),
        TourStopCoordinate(
          id: 'rel_3',
          name: 'Namirembe Cathedral',
          subtitle: 'Anglican Cathedral',
          latitude: 0.3150,
          longitude: 32.5586,
        ),
        TourStopCoordinate(
          id: 'rel_4',
          name: 'Gaddafi Mosque',
          subtitle: 'Uganda National Mosque (Old Kampala)',
          latitude: 0.3163,
          longitude: 32.5683,
        ),
        TourStopCoordinate(
          id: 'rel_5',
          name: 'Bahai Temple',
          subtitle: 'Kikaaya Hill Mother Temple',
          latitude: 0.3644,
          longitude: 32.5886,
        ),
        TourStopCoordinate(
          id: 'rel_6',
          name: 'Namugongo Martyrs Shrine',
          subtitle: 'Martyrs Memorial Trail',
          latitude: 0.3953,
          longitude: 32.6658,
        ),
        TourStopCoordinate(
          id: 'rel_7',
          name: 'BMK Cafe',
          subtitle: 'Tour End Point',
          latitude: 0.3182,
          longitude: 32.5898,
        ),
      ],
    ),
  ];
}