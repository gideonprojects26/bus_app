static Future<List<BackendRoute>> fetchRoutes() async {
    // We add the headers to ensure the server treats the app like a browser
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
      // This is the important part!
      // This will print the error in your terminal/debug console
      print('ERROR: Status Code ${response.statusCode}');
      print('ERROR: Response Body: ${response.body}');
      
      throw Exception('Failed to load routes. Status: ${response.statusCode}');
    }
  }