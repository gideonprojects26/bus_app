import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/booking_model.dart';

class PaymentService {
  static Future<Map<String, dynamic>> initiatePayment({
    required String token,
    required BookingDraft draft,
    required String paymentMethodChosen,
    String? phoneNumber,
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/payments/initiate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'routeId': draft.routeId,
        'pickupStop': draft.pickupStop,
        'bookingDate': draft.date.toIso8601String().split('T')[0],
        'bookingTime': draft.time,
        'seatCount': draft.passengers,
        'isLocal': draft.isLocal,
        'paymentMethodChosen': paymentMethodChosen,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        'email': email,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Failed to start payment.'};
    }
  }

  static Future<Map<String, dynamic>> checkStatus({
    required String token,
    required String txRef,
  }) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/payments/status/$txRef'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);
    return {'success': response.statusCode == 200, 'data': data};
  }
}