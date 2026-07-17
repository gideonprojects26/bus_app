import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class RentalService {
  static Future<Map<String, dynamic>> submitRentalRequest({
    required String token,
    required String fullName,
    required String phone,
    required int passengerCount,
    required DateTime neededDate,
    String? additionalDetails,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/rentals'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'fullName': fullName,
        'phone': phone,
        'passengerCount': passengerCount,
        'neededDate': neededDate.toIso8601String().split('T')[0],
        'additionalDetails': additionalDetails,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {'success': true};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Failed to submit request.'};
    }
  }
}