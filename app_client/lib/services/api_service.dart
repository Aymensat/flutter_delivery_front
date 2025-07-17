import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/restaurant.dart';
import '../models/food.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Base HTTP methods
  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}$endpoint'),
      headers: _headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('${AppConfig.baseUrl}$endpoint'),
      headers: _headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('${AppConfig.baseUrl}$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      return json.decode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }

  // Restaurant methods
  Future<List<Restaurant>> getRestaurants({double? lat, double? lon}) async {
    String endpoint = '/restaurants';

    // Add location parameters if provided
    if (lat != null && lon != null) {
      endpoint += '?lat=$lat&lon=$lon';
    }

    final response = await get(endpoint);
    final List<dynamic> data = response['data'] ?? response;

    return data.map((item) => Restaurant.fromJson(item)).toList();
  }

  Future<Restaurant> getRestaurantById(String id) async {
    final response = await get('/restaurants/$id');
    return Restaurant.fromJson(response['data'] ?? response);
  }

  // Food methods
  Future<List<Food>> getFoods() async {
    final response = await get('/food');
    final List<dynamic> data = response['data'] ?? response;

    return data.map((item) => Food.fromJson(item)).toList();
  }

  Future<List<Food>> getFoodsByRestaurant(String restaurantId) async {
    final response = await get('/food?restaurant=$restaurantId');
    final List<dynamic> data = response['data'] ?? response;

    return data.map((item) => Food.fromJson(item)).toList();
  }

  Future<Food> getFoodById(String id) async {
    final response = await get('/food/$id');
    return Food.fromJson(response['data'] ?? response);
  }

  // Search methods
  Future<List<Restaurant>> searchRestaurants(String query) async {
    final response = await get('/restaurants?search=$query');
    final List<dynamic> data = response['data'] ?? response;

    return data.map((item) => Restaurant.fromJson(item)).toList();
  }

  Future<List<Food>> searchFoods(String query) async {
    final response = await get('/food?search=$query');
    final List<dynamic> data = response['data'] ?? response;

    return data.map((item) => Food.fromJson(item)).toList();
  }

  // Location-based methods
  Future<List<Restaurant>> getNearbyRestaurants(
    double lat,
    double lon, {
    double? radius,
  }) async {
    String endpoint = '/geocode/restaurant-locations?lat=$lat&lon=$lon';
    if (radius != null) {
      endpoint += '&radius=$radius';
    }

    final response = await get(endpoint);
    final List<dynamic> data = response['data'] ?? response;

    return data.map((item) => Restaurant.fromJson(item)).toList();
  }

  // Cart methods
  Future<List<dynamic>> getCartItems() async {
    final response = await get('/cart');
    return response['data'] ?? response;
  }

  Future<Map<String, dynamic>> addToCart(String foodId, int quantity) async {
    final response = await post('/cart', {
      'food': foodId,
      'quantity': quantity,
    });
    return response['data'] ?? response;
  }

  Future<Map<String, dynamic>> updateCartItem(
    String cartItemId,
    int quantity,
  ) async {
    final response = await put('/cart/$cartItemId', {'quantity': quantity});
    return response['data'] ?? response;
  }

  Future<void> removeCartItem(String cartItemId) async {
    await delete('/cart/$cartItemId');
  }

  // Order methods
  Future<List<dynamic>> getOrders() async {
    final response = await get('/orders');
    return response['data'] ?? response;
  }

  Future<Map<String, dynamic>> createOrder(
    Map<String, dynamic> orderData,
  ) async {
    final response = await post('/orders', orderData);
    return response['data'] ?? response;
  }

  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    final response = await get('/orders/$orderId');
    return response['data'] ?? response;
  }

  Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    final response = await put('/orders/$orderId', {'status': status});
    return response['data'] ?? response;
  }

  // Auth methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await post('/auth/login', {
      'email': email,
      'password': password,
    });
    return response;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await post('/auth/register', userData);
    return response;
  }

  // User methods
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await get('/users/me');
    return response['data'] ?? response;
  }

  Future<Map<String, dynamic>> updateUser(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    final response = await put('/users/$userId', userData);
    return response['data'] ?? response;
  }

  Future<List<Food>> getFoodsByRestaurantId(String restaurantId) async {
    final response = await get('/foods?restaurant=$restaurantId');
    return (response['data'] as List)
        .map((foodJson) => Food.fromJson(foodJson))
        .toList();
  }

  // Payment methods
  Future<Map<String, dynamic>> createPayment(
    Map<String, dynamic> paymentData,
  ) async {
    final response = await post('/payments', paymentData);
    return response['data'] ?? response;
  }

  Future<List<dynamic>> getPayments() async {
    final response = await get('/payments');
    return response['data'] ?? response;
  }

  // Feedback methods
  Future<Map<String, dynamic>> createFeedback(
    Map<String, dynamic> feedbackData,
  ) async {
    final response = await post('/feedback', feedbackData);
    return response['data'] ?? response;
  }

  Future<List<dynamic>> getFeedback(String type, String id) async {
    final response = await get('/feedback/$type/$id');
    return response['data'] ?? response;
  }

  // Notification methods
  Future<List<dynamic>> getNotifications() async {
    final response = await get('/notifications');
    return response['data'] ?? response;
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await put('/notifications/$notificationId/read', {});
  }

  Future<void> markAllNotificationsAsRead() async {
    await put('/notifications/read-all', {});
  }
}
