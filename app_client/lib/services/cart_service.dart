// lib/services/cart_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/cart.dart';
import '../models/food.dart';
import 'auth_service.dart';

class CartService {
  final String _baseUrl = AppConfig.baseUrl;
  final AuthService _authService = AuthService();

  // CRITICAL FIX 2: Get cart items with proper Food object integration
  Future<List<CartItem>> getCartItems() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/cart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle both single cart object and array of cart items
        if (data is Map<String, dynamic>) {
          // If API returns a cart object with items array
          if (data['items'] != null) {
            return await _processCartItems(data['items']);
          }
          // If API returns a single cart item
          else {
            return await _processCartItems([data]);
          }
        } else if (data is List) {
          // If API returns array of cart items directly
          return await _processCartItems(data);
        }

        return [];
      } else {
        throw Exception('Failed to load cart items');
      }
    } catch (e) {
      throw Exception('Error fetching cart items: ${e.toString()}');
    }
  }

  // Helper method to process cart items and fetch food details
  Future<List<CartItem>> _processCartItems(List<dynamic> items) async {
    List<CartItem> cartItems = [];

    for (var item in items) {
      try {
        // Check if food is already a full object or just an ID
        Food? foodDetails;

        if (item['food'] is String) {
          // Food is just an ID, fetch full details
          foodDetails = await _fetchFoodDetails(item['food']);
        } else if (item['food'] is Map<String, dynamic>) {
          // Food is already a full object
          foodDetails = Food.fromJson(item['food']);
        }

        if (foodDetails != null) {
          cartItems.add(
            CartItem(
              id: item['_id'] ?? '',
              user: item['user'] ?? '',
              food: foodDetails,
              quantity: item['quantity'] ?? 1,
              price: (item['price'] ?? foodDetails.price).toDouble(),
              foodDetails: foodDetails, // Add food details for UI compatibility
            ),
          );
        }
      } catch (e) {
        print('Error processing cart item: $e');
        // Skip this item but continue processing others
      }
    }

    return cartItems;
  }

  // Fetch complete food details by ID
  Future<Food?> _fetchFoodDetails(String foodId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/foods/$foodId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Food.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching food details: $e');
      return null;
    }
  }

  // Add item to cart
  Future<Map<String, dynamic>> addToCart({
    required String foodId,
    required int quantity,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/cart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'food': foodId, 'quantity': quantity}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to add to cart',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Update cart item quantity
  Future<Map<String, dynamic>> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/cart/$cartItemId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to update cart item',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Remove item from cart
  Future<Map<String, dynamic>> removeFromCart(String cartItemId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/cart/$cartItemId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to remove from cart',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Clear entire cart
  Future<Map<String, dynamic>> clearCart() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/cart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to clear cart',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Get cart total
  Future<double> getCartTotal() async {
    try {
      final cartItems = await getCartItems();
      double total = 0.0;

      for (var item in cartItems) {
        total += (item.price * item.quantity);
      }

      return total;
    } catch (e) {
      print('Error calculating cart total: $e');
      return 0.0;
    }
  }

  // Get cart item count
  Future<int> getCartItemCount() async {
    try {
      final cartItems = await getCartItems();
      int count = 0;

      for (var item in cartItems) {
        count += item.quantity;
      }

      return count;
    } catch (e) {
      print('Error calculating cart item count: $e');
      return 0;
    }
  }
}
