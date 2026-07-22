import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/backend_route_model.dart';

class RouteService {
  static Future<List<BackendRoute>> fetchRoutes() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/routes'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => BackendRoute.fromJson(json)).toList();
      } else {
        print('DEBUG: Request failed with status: ${response.statusCode}');
        print('DEBUG: Response body: ${response.body}');
        throw Exception('Failed to load routes. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Exception caught: $e');
      throw Exception('Network error: $e');
    }
  }
}