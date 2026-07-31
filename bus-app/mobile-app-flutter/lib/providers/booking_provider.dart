import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Make sure shared_preferences is in pubspec.yaml
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

  /// Retrieve stored authentication token from device storage
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    // Change 'token' below to the exact key name you used when saving the token during login
    return prefs.getString('token') ?? prefs.getString('userToken');
  }

  /// Fetch user bookings from backend API
  Future<void> fetchUserBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final url = Uri.parse('https://bus-app-backend-hrxf.onrender.com/api/bookings');

    try {
      final token = await _getToken();

      // Handle case where user is not logged in / token is missing
      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication missing. Please log in again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // <--- FIX: Added Authorization header
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _bookings = data.map((json) => BookingModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        _errorMessage = 'Session expired. Please log in again.';
      } else {
        _errorMessage = 'Failed to load bookings from server (${response.statusCode})';
      }
    } catch (error) {
      _errorMessage = 'Network error: Unable to connect to backend server.';
      debugPrint('Fetch Bookings Error: $error');
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
        final token = await _getToken();

        await http.patch(
          Uri.parse('https://bus-app-backend-hrxf.onrender.com/api/bookings/$id/cancel'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token', // <--- FIX: Added Authorization header
          },
        );
      } catch (e) {
        debugPrint('Error updating cancelled status on backend: $e');
      }
    }
  }
}