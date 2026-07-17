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
}
