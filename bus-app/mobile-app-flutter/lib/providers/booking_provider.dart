import 'package:flutter/material.dart';
import '../models/booking_model.dart';

class BookingProvider with ChangeNotifier {
  final List<BookingModel> _bookings = [];

  List<BookingModel> get allBookings => _bookings;

  List<BookingModel> get upcoming =>
      _bookings.where((b) => b.status == 'upcoming').toList();

  List<BookingModel> get completed =>
      _bookings.where((b) => b.status == 'completed').toList();

  List<BookingModel> get cancelled =>
      _bookings.where((b) => b.status == 'cancelled').toList();

  void addBooking(BookingModel booking) {
    _bookings.add(booking);
    notifyListeners();
  }

  void cancelBooking(String id) {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      final old = _bookings[index];
      _bookings[index] = BookingModel(
        id: old.id,
        draft: old.draft,
        paymentMethod: old.paymentMethod,
        status: 'cancelled',
        createdAt: old.createdAt,
      );
      notifyListeners();
    }
  }
}
