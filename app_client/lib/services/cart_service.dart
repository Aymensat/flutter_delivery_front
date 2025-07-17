// lib/services/cart_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/cart.dart'; // Ensure this is imported and correctly defines `Cart`
import 'auth_service.dart'; // Ensure this is imported
import 'package:flutter/foundation.dart';

class CartService {
  final String _baseUrl = AppConfig.baseUrl;
  final AuthService _authService = AuthService();

  // FIX: Change return type from List<CartItem> to List<Cart>
  Future<List<Cart>> getCartItems() async {
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

        // FIX: Handle API response consistently for a list of Cart objects
        if (data is List) {
          // If the API returns an array of cart items directly
          return data.map((json) => Cart.fromJson(json)).toList();
        } else if (data is Map<String, dynamic> && data['items'] is List) {
          // If the API returns a cart object with an 'items' array
          return (data['items'] as List)
              .map((json) => Cart.fromJson(json))
              .toList();
        } else {
          // If the API returns a single cart item
          return [Cart.fromJson(data)];
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load cart items');
      }
    } catch (e) {
      debugPrint('Error getting cart items: $e'); // Use debugPrint
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // FIX: Add named parameters userId and token, change foodId to String
  Future<Map<String, dynamic>> addItemToCart({
    required String userId,
    required String foodId,
    required int quantity,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/cart/add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'foodId': foodId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to add item to cart');
      }
    } catch (e) {
      debugPrint('Error adding item to cart: $e'); // Use debugPrint
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // FIX: Add named parameters userId and token
  Future<Map<String, dynamic>> updateCartItemQuantity({
    required String userId,
    required String cartItemId,
    required int quantity,
    required String token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/cart/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'cartItemId': cartItemId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to update cart item quantity',
        );
      }
    } catch (e) {
      debugPrint('Error updating cart item quantity: $e'); // Use debugPrint
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // FIX: Add named parameters userId and token
  Future<Map<String, dynamic>> removeCartItem({
    required String userId,
    required String cartItemId,
    required String token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/cart/remove'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'userId': userId, 'cartItemId': cartItemId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to remove cart item');
      }
    } catch (e) {
      debugPrint('Error removing cart item: $e'); // Use debugPrint
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // FIX: Clear cart method signature for userId and token
  Future<Map<String, dynamic>> clearCart(String userId, String token) async {
    try {
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/cart/clear'), // Assuming a specific clear endpoint
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'userId': userId}),
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
      debugPrint('Error clearing cart: $e'); // Use debugPrint
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // FIX: Update getCartTotal to use Cart properties, fix double to int assignment
  Future<double> getCartTotal() async {
    try {
      final cartItems = await getCartItems();
      double total = 0.0;

      for (var item in cartItems) {
        total += item.totalPrice; // Use totalPrice from Cart model
      }

      return total;
    } catch (e) {
      debugPrint('Error calculating cart total: $e'); // Use debugPrint
      return 0.0;
    }
  }

  // Get cart item count (No change needed here based on previous error log)
  Future<int> getCartItemCount() async {
    try {
      final cartItems = await getCartItems();
      return cartItems.fold<int>(0, (int sum, item) => sum + item.quantity);
    } catch (e) {
      debugPrint('Error getting cart item count: $e');
      return 0;
    }
  }
}
