import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Fixes avoid_print using debugPrint
import 'package:http/http.dart' as http; // Fixes package URI error
import 'dart:convert';
import '../models/booking_model.dart';

class BookingProvider with ChangeNotifier {
  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BookingModel> get allBookings => _bookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<BookingModel> get upcoming =>
      _bookings.where((b) => b.status == 'upcoming' || b.status == 'confirmed').toList();

  List<BookingModel> get completed =>
      _bookings.where((b) => b.status == 'completed').toList();

  List<BookingModel> get cancelled =>
      _bookings.where((b) => b.status == 'cancelled').toList();

  /// Fetch user bookings from backend API
  Future<void> fetchUserBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final url = Uri.parse('https://bus-app-backend-hrxf.onrender.com/api/bookings');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _bookings = data.map((json) => BookingModel.fromJson(json)).toList();
      } else {
        _errorMessage = 'Failed to load bookings from server (${response.statusCode})';
      }
    } catch (error) {
      _errorMessage = 'Network error: Unable to connect to backend server.';
      debugPrint('Fetch Bookings Error: $error'); // Fixed print warning
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addBooking(BookingModel booking) {
    _bookings.add(booking);
    notifyListeners();
  }

  Future<void> cancelBooking(String id) async {
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

      try {
        await http.patch(
          Uri.parse('https://bus-app-backend-hrxf.onrender.com/api/bookings/$id/cancel'),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        debugPrint('Error updating cancelled status on backend: $e'); // Fixed print warning
      }
    }
  }
}