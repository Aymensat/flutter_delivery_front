// lib/providers/cart_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart.dart';
import '../services/cart_service.dart';
import '../providers/auth_provider.dart';
import '../models/user_public_profile.dart';
import '../models/food.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();

  List<Cart> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Cart> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalAmount {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  Future<void> loadCart(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        _cartItems = [];
        throw Exception('User not authenticated.');
      }
      _cartItems = await _cartService.fetchCart();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(Food food, BuildContext context, {List<String> excludedIngredients = const []}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;
      if (userId == null) {
        throw Exception('User not logged in.');
      }

      // The backend now correctly handles creating new items or updating quantity.
      await _cartService.addItemToCart(
        foodId: food.id,
        quantity: 1,
        userId: userId,
        excludedIngredients: excludedIngredients,
      );
      
      // After any modification, reload the cart from the backend to get the single source of truth.
      await loadCart(context);

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCartItem(String cartItemId, int quantity, List<String> excludedIngredients, BuildContext context) async {
    if (quantity <= 0) {
      await removeFromCart(cartItemId, context);
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _cartService.updateCartItem(cartItemId, quantity, excludedIngredients);
      await loadCart(context); // Reload cart from server
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String cartItemId, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _cartService.removeCartItem(cartItemId);
      await loadCart(context); // Reload cart from server
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _cartService.clearCart();
      _cartItems.clear();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}