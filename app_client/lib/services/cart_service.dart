// lib/services/cart_service.dart
import 'dart:convert';
import '../config/app_config.dart';
import 'api_service.dart';
import '../models/cart.dart';
import 'auth_service.dart'; // To get token and user ID
import '../models/user_public_profile.dart'; // Import UserPublicProfile to get user ID

class CartService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  Future<List<Cart>> fetchCart() async {
    try {
      final response = await _apiService.get('/cart');
      if (response is List) {
        return response.map((item) => Cart.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Failed to fetch cart: $e');
      throw Exception(
        'Failed to load cart items: $e',
      ); // Include error for better debugging
    }
  }

  // Modified: Accept userId as an argument
  Future<Cart> addItemToCart({
    required String foodId,
    int quantity = 1,
    required String userId, // Now explicitly required
  }) async {
    try {
      final response = await _apiService.post('/cart', {
        'foodId': foodId,
        'quantity': quantity,
        'user': userId, // Use the provided userId
      });
      return Cart.fromJson(response);
    } catch (e) {
      print('Failed to add item to cart: $e');
      throw Exception(
        'Failed to add item to cart: $e',
      ); // Include error for better debugging
    }
  }

  Future<Cart> updateCartItemQuantity(String cartItemId, int quantity) async {
    try {
      // The backend PUT /cart/:id route uses 'protect' middleware,
      // so it extracts userId from the token. We don't need to send 'user' in the body here.
      final response = await _apiService.put('/cart/$cartItemId', {
        'quantity': quantity,
      });
      return Cart.fromJson(response);
    } catch (e) {
      print('Failed to update cart item quantity: $e');
      throw Exception(
        'Failed to update cart item: $e',
      ); // Include error for better debugging
    }
  }

  Future<void> removeCartItem(String cartItemId) async {
    try {
      await _apiService.delete('/cart/$cartItemId');
    } catch (e) {
      print('Failed to remove cart item: $e');
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      await _apiService.delete('/cart/clear');
    } catch (e) {
      print('Failed to clear cart: $e');
      throw Exception('Failed to clear cart: $e');
    }
  }
}
