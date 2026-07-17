import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/backend_route_model.dart';

class RouteService {
  static Future<List<BackendRoute>> fetchRoutes() async {
    final response = await http.get(Uri.parse('${AppConstants.baseUrl}/routes'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => BackendRoute.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load routes.');
    }
  }
}