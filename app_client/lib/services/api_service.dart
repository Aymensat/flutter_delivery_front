// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';
import '../models/restaurant.dart'; // Import Restaurant model
import '../models/food.dart'; // Import Food model

class ApiService {
  final String _baseUrl = AppConfig.baseUrl;
  final AuthService _authService = AuthService(); // AuthService dependency

  // Method to load token, primarily for initial app startup in main.dart
  // It delegates to AuthService, as AuthService is responsible for token management.
  Future<String?> loadToken() async {
    return await _authService.getToken();
  }

  // Generic GET request
  Future<dynamic> get(String endpoint) async {
    final token = await _authService.getToken(); // Await the Future<String?>
    // Handle the case where token might be null
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }
    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  // Generic POST request with JSON data
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }
    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  // NEW: Generic PUT request with JSON data
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }
    final response = await http.put(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  // NEW: Generic DELETE request
  Future<dynamic> delete(String endpoint) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }
    final response = await http.delete(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  // Method for POST/PUT with multipart/form-data
  Future<dynamic> multipartRequest(
    String method, // 'POST' or 'PUT'
    String endpoint,
    Map<String, String> fields,
    String? filePath,
    String fileField,
  ) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }
    var request = http.MultipartRequest(
      method,
      Uri.parse('$_baseUrl$endpoint'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);

    if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    }

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    print('Multipart request to $endpoint finished with status code ${response.statusCode}');
    print('Response data: $responseData');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(responseData);
    } else {
      throw Exception(
        'Failed multipart request: ${response.statusCode}. Response: $responseData',
      );
    }
  }

  // Specific API calls for restaurants (used by RestaurantProvider)
  Future<List<Restaurant>> getRestaurants({double? lat, double? lon}) async {
    String endpoint = '/restaurants';
    // If location is provided, add it as query parameters
    if (lat != null && lon != null) {
      endpoint += '?latitude=$lat&longitude=$lon';
    }
    final response = await get(endpoint);
    return (response as List).map((json) => Restaurant.fromJson(json)).toList();
  }

  Future<Restaurant> getRestaurantById(String id) async {
    final response = await get('/restaurants/$id');
    return Restaurant.fromJson(response);
  }

  // Specific API calls for foods (used by RestaurantProvider)
  Future<List<Food>> getFoods() async {
    final response = await get('/foods');
    return (response as List).map((json) => Food.fromJson(json)).toList();
  }

  Future<List<Food>> getFoodsByRestaurantId(String restaurantId) async {
    final response = await get('/restaurants/$restaurantId/foods');
    return (response as List).map((json) => Food.fromJson(json)).toList();
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return {}; // Return empty map for 204 No Content or similar
    } else {
      final errorBody = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : 'No error message';
      throw Exception(
        'API call failed: ${response.statusCode}. Error: $errorBody',
      );
    }
  }
}
