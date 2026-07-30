class BookingDraft {
  final String routeId;
  final String routeName;
  final String pickupStop;
  final DateTime date;
  final String time;
  final int passengers;
  final bool isLocal;
  final double totalPrice;
  final String currency;

  BookingDraft({
    required this.routeId,
    required this.routeName,
    required this.pickupStop,
    required this.date,
    required this.time,
    required this.passengers,
    required this.isLocal,
    required this.totalPrice,
    required this.currency,
  });

  /// Factory to construct BookingDraft from JSON/Map (handles snake_case & camelCase)
  factory BookingDraft.fromJson(Map<String, dynamic> json) {
    return BookingDraft(
      routeId: json['route_id']?.toString() ?? json['routeId']?.toString() ?? '',
      routeName: json['route_name'] ?? json['routeName'] ?? 'Unknown Route',
      pickupStop: json['pickup_stop'] ?? json['pickupStop'] ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      time: json['time'] ?? '',
      passengers: (json['passengers'] ?? 1) is int
          ? json['passengers'] ?? 1
          : int.tryParse(json['passengers'].toString()) ?? 1,
      isLocal: json['is_local'] ?? json['isLocal'] ?? true,
      totalPrice: (json['total_price'] ?? json['totalPrice'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'UGX',
    );
  }

  /// Convert BookingDraft instance back to JSON
  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'route_name': routeName,
      'pickup_stop': pickupStop,
      'date': date.toIso8601String(),
      'time': time,
      'passengers': passengers,
      'is_local': isLocal,
      'total_price': totalPrice,
      'currency': currency,
    };
  }
}

class BookingModel {
  final String id;
  final BookingDraft draft;
  final String paymentMethod;
  final String status; // upcoming, completed, cancelled
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.draft,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  /// Factory to construct BookingModel from JSON/Map
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? '',
      paymentMethod: json['payment_method'] ?? json['paymentMethod'] ?? 'pesapal',
      status: json['status'] ?? 'upcoming',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      // Handles both nested draft objects (e.g., json['draft']) 
      // or flat JSON payloads from SQL JOIN queries
      draft: json['draft'] != null && json['draft'] is Map<String, dynamic>
          ? BookingDraft.fromJson(json['draft'])
          : BookingDraft.fromJson(json),
    );
  }

  /// Convert BookingModel instance back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_method': paymentMethod,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'draft': draft.toJson(),
    };
  }
}