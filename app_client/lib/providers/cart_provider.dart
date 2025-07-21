// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../services/cart_service.dart';
// import '../services/auth_service.dart'; // No longer explicitly needed here if CartService handles it internally.

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  // Removed AuthService as it's not directly used in CartProvider's logic anymore,
  // CartService handles auth token internally.
  // final AuthService _authService = AuthService(); // REMOVED: No longer used directly

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

  CartProvider() {
    loadCart();
  }

  Future<void> loadCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cartItems = await _cartService.fetchCart();
    } catch (e) {
      _errorMessage = e.toString();
      _cartItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Renamed from addItemToCart to addToCart to match restaurant_detail_screen.dart
  Future<void> addToCart(String foodId, {int quantity = 1}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Pass named parameters correctly
      final newItem = await _cartService.addItemToCart(
        foodId: foodId,
        quantity: quantity,
      );
      // Check if item already exists in cart and update quantity, otherwise add new
      int index = _cartItems.indexWhere(
        (item) => item.food.id == newItem.food.id,
      );
      if (index != -1) {
        _cartItems[index] = newItem; // Update existing item
      } else {
        _cartItems.add(newItem);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedItem = await _cartService.updateCartItemQuantity(
        cartItemId,
        quantity,
      );
      int index = _cartItems.indexWhere((item) => item.id == cartItemId);
      if (index != -1) {
        _cartItems[index] = updatedItem;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _cartService.removeCartItem(cartItemId);
      _cartItems.removeWhere((item) => item.id == cartItemId);
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
      // Assuming cart_service.dart clearCart no longer needs userId and token arguments
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
    // Renamed from clearError for consistency
    _errorMessage = null;
    notifyListeners();
  }

  Cart? getCartItem(String foodId) {
    try {
      return _cartItems.firstWhere((item) => item.food.id == foodId);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    //TODO implement this method
  }
}
